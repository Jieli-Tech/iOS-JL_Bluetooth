#!/usr/bin/env python3
import sys
import struct
import json
import argparse
from dataclasses import dataclass, asdict
from typing import Optional, Tuple, List, Dict


class OpusInspector:
    """OPUS 文件解析器：支持 Ogg Opus 容器与裸包的头部检测、帧结构解析与完整性判断"""

    def __init__(self, data: bytes):
        self.data = data

    def analyze(self) -> Dict:
        if self._is_ogg(self.data):
            return self._analyze_ogg_opus(self.data)
        return self._analyze_raw_opus(self.data)

    def _is_ogg(self, data: bytes) -> bool:
        return len(data) >= 4 and data[:4] == b"OggS"

    def _analyze_ogg_opus(self, data: bytes) -> Dict:
        try:
            pages = self._iter_ogg_pages(data)
            head_page = next(pages)
            payload = head_page[3]
            if not payload.startswith(b"OpusHead"):
                raise ValueError("首页缺少 OpusHead")
            head = self._parse_opus_head(payload)
            audio_packet = None
            vendor = None
            comments: List[str] = []
            checked_packets = 0
            incomplete_packets = 0
            unknown_packets = 0
            last_packet_complete: Optional[bool] = None
            for page in pages:
                if page[3].startswith(b"OpusTags"):
                    v, cs = self._parse_opus_tags(page[3])
                    vendor, comments = v, cs
                    continue
                pkts = self._split_ogg_packets(page[3], page[2])
                for pkt in pkts:
                    if audio_packet is None:
                        audio_packet = pkt
                    comp, reason = self._is_complete_packet(pkt)
                    if comp is True:
                        checked_packets += 1
                        last_packet_complete = True
                    elif comp is False:
                        checked_packets += 1
                        incomplete_packets += 1
                        last_packet_complete = False
                    else:
                        unknown_packets += 1
                        last_packet_complete = None
            frames_complete: Optional[bool]
            if checked_packets == 0 and unknown_packets > 0:
                frames_complete = None
            elif unknown_packets > 0:
                frames_complete = None
            else:
                frames_complete = (incomplete_packets == 0)
            toc_info = self._parse_toc(audio_packet[0]) if audio_packet else None
            frame_sizes = self._parse_packet_frames(audio_packet) if audio_packet else None
            frame_count = len(frame_sizes) if frame_sizes else (1 if toc_info and toc_info.frame_count_code == 0 else (2 if toc_info and toc_info.frame_count_code == 1 else None))
            frame_bytes = frame_sizes[0] if frame_sizes and len(set(frame_sizes)) == 1 else None
            report = OpusReport(
                container_valid=True,
                header_valid=True,
                channels=head.channels,
                sample_rate=head.input_sample_rate or 48000,
                mapping_family=head.mapping_family,
                frame_duration_ms=toc_info.frame_duration_ms if toc_info else None,
                frame_count_code=toc_info.frame_count_code if toc_info else None,
                mode=toc_info.mode if toc_info else None,
                bandwidth=toc_info.bandwidth if toc_info else None,
                bytes_per_frame=frame_bytes,
                frame_count=frame_count,
                frame_sizes=frame_sizes,
                tags_vendor=vendor,
                tags_comments=comments,
                notes=None,
                frames_complete=frames_complete,
                checked_packets=checked_packets,
                incomplete_packets=incomplete_packets,
                unknown_packets=unknown_packets,
                last_packet_complete=last_packet_complete,
            )
            return report.to_dict()
        except Exception as e:
            return OpusReport(
                container_valid=False,
                header_valid=False,
                channels=None,
                sample_rate=None,
                mapping_family=None,
                frame_duration_ms=None,
                frame_count_code=None,
                mode=None,
                bandwidth=None,
                bytes_per_frame=None,
                frame_count=None,
                frame_sizes=None,
                tags_vendor=None,
                tags_comments=None,
                notes=str(e),
                frames_complete=None,
                checked_packets=None,
                incomplete_packets=None,
                unknown_packets=None,
                last_packet_complete=None,
            ).to_dict()

    def _analyze_raw_opus(self, data: bytes) -> Dict:
        try:
            if not data:
                raise ValueError("空文件")
            toc = data[0]
            toc_info = self._parse_toc(toc)
            frame_sizes = self._parse_packet_frames(data)
            frame_count = len(frame_sizes) if frame_sizes else (1 if toc_info and toc_info.frame_count_code == 0 else (2 if toc_info and toc_info.frame_count_code == 1 else None))
            frame_bytes = frame_sizes[0] if frame_sizes and len(set(frame_sizes)) == 1 else None
            comp, reason = self._is_complete_packet(data)
            frames_complete: Optional[bool]
            checked_packets: Optional[int]
            incomplete_packets: Optional[int]
            unknown_packets: Optional[int]
            last_packet_complete: Optional[bool]
            if comp is True:
                frames_complete = True
                checked_packets = 1
                incomplete_packets = 0
                unknown_packets = 0
                last_packet_complete = True
            elif comp is False:
                frames_complete = False
                checked_packets = 1
                incomplete_packets = 1
                unknown_packets = 0
                last_packet_complete = False
            else:
                frames_complete = None
                checked_packets = 0
                incomplete_packets = 0
                unknown_packets = 1
                last_packet_complete = None
            report = OpusReport(
                container_valid=False,
                header_valid=False,
                channels=None,
                sample_rate=None,
                mapping_family=None,
                frame_duration_ms=toc_info.frame_duration_ms,
                frame_count_code=toc_info.frame_count_code,
                mode=toc_info.mode,
                bandwidth=toc_info.bandwidth,
                bytes_per_frame=frame_bytes,
                frame_count=frame_count,
                frame_sizes=frame_sizes,
                tags_vendor=None,
                tags_comments=None,
                notes=("裸包模式：仅基于 TOC 推断部分参数" + (f"；完整性提示：{reason}" if reason else "")),
                frames_complete=frames_complete,
                checked_packets=checked_packets,
                incomplete_packets=incomplete_packets,
                unknown_packets=unknown_packets,
                last_packet_complete=last_packet_complete,
            )
            return report.to_dict()
        except Exception as e:
            return OpusReport(
                container_valid=False,
                header_valid=False,
                channels=None,
                sample_rate=None,
                mapping_family=None,
                frame_duration_ms=None,
                frame_count_code=None,
                mode=None,
                bandwidth=None,
                bytes_per_frame=None,
                frame_count=None,
                frame_sizes=None,
                tags_vendor=None,
                tags_comments=None,
                notes=str(e),
                frames_complete=None,
                checked_packets=None,
                incomplete_packets=None,
                unknown_packets=None,
                last_packet_complete=None,
            ).to_dict()

    def _iter_ogg_pages(self, data: bytes):
        off = 0
        while off + 27 <= len(data):
            if data[off:off+4] != b"OggS":
                raise ValueError("Ogg 标识错误")
            header = data[off:off+27]
            seg_cnt = header[26]
            if off + 27 + seg_cnt > len(data):
                raise ValueError("段表越界")
            lacing = data[off+27:off+27+seg_cnt]
            pkt_sizes = []
            size_acc = 0
            page_data_start = off + 27 + seg_cnt
            page_data_end = page_data_start
            for b in lacing:
                size_acc += b
                page_data_end += b
                if b < 255:
                    pkt_sizes.append(size_acc)
                    size_acc = 0
            payload = data[page_data_start:page_data_end]
            yield (header, lacing, pkt_sizes, payload)
            off = page_data_end

    def _split_ogg_packets(self, payload: bytes, pkt_sizes: List[int]) -> List[bytes]:
        packets = []
        off = 0
        for sz in pkt_sizes:
            if off + sz <= len(payload):
                packets.append(payload[off:off+sz])
                off += sz
            else:
                break
        return packets

    def _parse_opus_tags(self, payload: bytes) -> Tuple[Optional[str], List[str]]:
        if not payload.startswith(b"OpusTags"):
            return None, []
        off = 8
        if off + 4 > len(payload):
            return None, []
        vendor_len = struct.unpack_from("<I", payload, off)[0]
        off += 4
        if off + vendor_len > len(payload):
            return None, []
        vendor = payload[off:off+vendor_len].decode(errors="ignore")
        off += vendor_len
        if off + 4 > len(payload):
            return vendor, []
        n_comments = struct.unpack_from("<I", payload, off)[0]
        off += 4
        comments: List[str] = []
        for _ in range(n_comments):
            if off + 4 > len(payload):
                break
            clen = struct.unpack_from("<I", payload, off)[0]
            off += 4
            if off + clen > len(payload):
                break
            comments.append(payload[off:off+clen].decode(errors="ignore"))
            off += clen
        return vendor, comments

    def _parse_opus_head(self, payload: bytes):
        if not payload.startswith(b"OpusHead"):
            raise ValueError("缺少 OpusHead")
        if len(payload) < 19:
            raise ValueError("OpusHead 长度不足")
        ver = payload[8]
        ch = payload[9]
        pre_skip = struct.unpack_from("<H", payload, 10)[0]
        rate = struct.unpack_from("<I", payload, 12)[0]
        gain = struct.unpack_from("<h", payload, 16)[0]
        mapping = payload[18]
        return OpusHead(version=ver, channels=ch, pre_skip=pre_skip, input_sample_rate=rate, output_gain=gain, mapping_family=mapping)

    def _parse_toc(self, toc_byte: int):
        config = toc_byte & 0x1F
        fc = (toc_byte >> 6) & 0x03
        mode, bw, fd = self._config_to_params(config)
        return TocInfo(frame_count_code=fc, mode=mode, bandwidth=bw, frame_duration_ms=fd)

    def _config_to_params(self, config: int) -> Tuple[str, str, float]:
        if 0 <= config <= 3:
            return ("SILK", "NB", [10.0, 20.0, 40.0, 60.0][config % 4])
        if 4 <= config <= 7:
            return ("SILK", "MB", [10.0, 20.0, 40.0, 60.0][config % 4])
        if 8 <= config <= 11:
            return ("SILK", "WB", [10.0, 20.0, 40.0, 60.0][config % 4])
        if 12 <= config <= 13:
            return ("HYBRID", "SWB", [10.0, 20.0][config - 12])
        if 14 <= config <= 15:
            return ("HYBRID", "FB", [10.0, 20.0][config - 14])
        if 16 <= config <= 19:
            return ("CELT", "NB", [2.5, 5.0, 10.0, 20.0][config - 16])
        if 20 <= config <= 23:
            return ("CELT", "WB", [2.5, 5.0, 10.0, 20.0][config - 20])
        if 24 <= config <= 27:
            return ("CELT", "SWB", [2.5, 5.0, 10.0, 20.0][config - 24])
        if 28 <= config <= 31:
            return ("CELT", "FB", [2.5, 5.0, 10.0, 20.0][config - 28])
        raise ValueError("无效 TOC 配置")

    def _estimate_frame_bytes(self, packet: Optional[bytes], toc: Optional['TocInfo']) -> Optional[int]:
        if not packet or not toc:
            return None
        fc = toc.frame_count_code
        plen = len(packet)
        if fc == 0:
            return plen - 1
        if fc == 1:
            return (plen - 1) // 2
        return None

    def _parse_packet_frames(self, packet: Optional[bytes]) -> Optional[List[int]]:
        if not packet or len(packet) < 2:
            return None
        toc = packet[0]
        fc = (toc >> 6) & 0x03
        payload = packet[1:]
        if fc == 0:
            return [len(payload)]
        if fc == 1:
            if len(payload) % 2 == 0:
                half = len(payload) // 2
                return [half, half]
            return None
        # fc==2 or fc==3: assume next byte is number of frames (best-effort)
        nframes = payload[0]
        remaining = payload[1:]
        if nframes <= 0:
            return None
        if fc == 3:
            # CBR: equally split
            if len(remaining) % nframes == 0:
                size = len(remaining) // nframes
                return [size] * nframes
            return None
        if fc == 2:
            # VBR: we cannot reliably parse lengths without full spec; best-effort fallback
            # return frame count only; sizes unknown
            return None
        return None

    def _is_complete_packet(self, packet: Optional[bytes]) -> Tuple[Optional[bool], Optional[str]]:
        """判断单个 Opus 包的帧是否完整

        返回 (完整性, 原因)。完整性为 True/False/None（None 表示无法判断）。
        依据 TOC 的帧数编码：
        - fc==0：单帧，无长度表，视为完整（无法进一步验证是否被截断）
        - fc==1：双帧等长，负载需为偶数，否则视为不完整
        - fc==3：CBR 多帧，需满足剩余字节能被帧数整除，否则不完整
        - fc==2：VBR 多帧，长度表解析复杂，此处返回未知
        """
        if not packet or len(packet) < 2:
            return False, "数据长度不足以解析 TOC"
        toc = packet[0]
        fc = (toc >> 6) & 0x03
        payload = packet[1:]
        if fc == 0:
            return True, None
        if fc == 1:
            if len(payload) % 2 == 0:
                return True, None
            return False, "双帧等长但负载字节非偶数"
        if fc == 3:
            if len(payload) < 1:
                return False, "CBR 模式缺少帧数字段"
            nframes = payload[0]
            remaining = payload[1:]
            if nframes <= 0:
                return False, "CBR 模式帧数为 0"
            if len(remaining) % nframes == 0:
                return True, None
            return False, "CBR 模式剩余字节无法整除帧数"
        if fc == 2:
            return None, "VBR 模式无法可靠判断完整性"
        return None, "未知帧数编码"


@dataclass
class OpusHead:
    """OpusHead 结构解析结果"""
    version: int
    channels: int
    pre_skip: int
    input_sample_rate: int
    output_gain: int
    mapping_family: int


@dataclass
class TocInfo:
    """TOC 字节解析结果：帧数编码、模式与带宽、帧时长"""
    frame_count_code: int
    mode: str
    bandwidth: str
    frame_duration_ms: float


@dataclass
class OpusReport:
    """OPUS 解析报告：容器与头部有效性、核心音频参数、帧完整性统计与错误说明"""
    container_valid: bool
    header_valid: bool
    channels: Optional[int]
    sample_rate: Optional[int]
    mapping_family: Optional[int]
    frame_duration_ms: Optional[float]
    frame_count_code: Optional[int]
    mode: Optional[str]
    bandwidth: Optional[str]
    bytes_per_frame: Optional[int]
    frame_count: Optional[int]
    frame_sizes: Optional[List[int]]
    tags_vendor: Optional[str]
    tags_comments: Optional[List[str]]
    notes: Optional[str]
    frames_complete: Optional[bool]
    checked_packets: Optional[int]
    incomplete_packets: Optional[int]
    unknown_packets: Optional[int]
    last_packet_complete: Optional[bool]

    def to_dict(self) -> Dict:
        return asdict(self)


def load_file(path: str) -> bytes:
    with open(path, "rb") as f:
        return f.read()


def main(argv: List[str]):
    parser = argparse.ArgumentParser(description="OPUS 文件解析器（可直接运行并按提示输入路径）")
    parser.add_argument("path", nargs="?", help="OPUS 文件路径")
    parser.add_argument("--json", action="store_true", help="以 JSON 格式输出")
    args = parser.parse_args(argv[1:])
    path = args.path
    if not path:
        try:
            path = input("请输入 OPUS 文件路径: ").strip()
        except EOFError:
            print("错误: 未提供文件路径")
            return 2
    if not path:
        print("错误: 未提供文件路径")
        return 2
    try:
        data = load_file(path)
        report = OpusInspector(data).analyze()
        if args.json:
            print(json.dumps(report, ensure_ascii=False, indent=2))
        else:
            for k, v in report.items():
                print(f"{k}: {v}")
        return 0
    except FileNotFoundError:
        print(f"错误: 文件不存在: {path}")
        return 2
    except PermissionError:
        print(f"错误: 无法访问文件（权限问题）: {path}")
        return 2
    except Exception as e:
        print(f"错误: {e}")
        return 2


if __name__ == "__main__":
    sys.exit(main(sys.argv))
