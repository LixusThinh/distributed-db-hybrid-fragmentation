"""Vẽ các sơ đồ dùng cho slide và báo cáo.

Chạy:  python assets/diagrams/gen_diagrams.py
Kết quả: assets/diagrams/*.png (200 dpi, dùng cho Word/slide) và *.svg (phóng to không vỡ).
"""
from pathlib import Path

import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt
from matplotlib.patches import FancyBboxPatch, Ellipse, Rectangle

OUT = Path(__file__).resolve().parent
# Segoe UI cho chữ tiếng Việt; DejaVu Sans bù các ký hiệu ⋈ ⋉ ∪ mà Segoe UI không có
plt.rcParams["font.family"] = ["Segoe UI", "DejaVu Sans"]
plt.rcParams["svg.fonttype"] = "none"

# Màu cố định cho 4 site (khớp ghi chú trong slides/noi_dung_slide.md)
SITE = {
    "S0": ("#4B5563", "#E5E7EB", "S0 – Trụ sở"),
    "S1": ("#DC2626", "#FEE2E2", "S1 – Hà Nội"),
    "S2": ("#16A34A", "#DCFCE7", "S2 – Đà Nẵng"),
    "S3": ("#2563EB", "#DBEAFE", "S3 – TP.HCM"),
}
SIGMA = ("#D97706", "#FEF3C7")   # nút chọn σ
PI = ("#7C3AED", "#EDE9FE")      # nút chiếu π
ROOT = ("#111827", "#F9FAFB")
INK = "#111827"


def canvas(w, h, xlim, ylim):
    fig, ax = plt.subplots(figsize=(w, h))
    ax.set_xlim(*xlim)
    ax.set_ylim(*ylim)
    ax.axis("off")
    return fig, ax


def box(ax, x, y, w, h, text, ec, fc, size=11, weight="normal", lw=1.6, align="center", style="round,pad=0.02,rounding_size=0.12"):
    ax.add_patch(FancyBboxPatch((x - w / 2, y - h / 2), w, h, boxstyle=style, ec=ec, fc=fc, lw=lw))
    ha = "center" if align == "center" else "left"
    tx = x if align == "center" else x - w / 2 + 0.15
    ax.text(tx, y, text, ha=ha, va="center", fontsize=size, color=INK, weight=weight, linespacing=1.35)


def arrow(ax, x1, y1, x2, y2, label=None, color="#6B7280", size=10, lw=1.4, both=False, lx=0.0, ly=0.0):
    ax.annotate("", xy=(x2, y2), xytext=(x1, y1),
                arrowprops=dict(arrowstyle="<|-|>" if both else "-|>", color=color, lw=lw, shrinkA=2, shrinkB=2))
    if label:
        ax.text((x1 + x2) / 2 + lx, (y1 + y2) / 2 + ly, label, ha="center", va="center", fontsize=size, color=color,
                bbox=dict(boxstyle="round,pad=0.15", fc="white", ec="none"))


def save(fig, name):
    fig.savefig(OUT / f"{name}.png", dpi=200, bbox_inches="tight", facecolor="white")
    fig.savefig(OUT / f"{name}.svg", bbox_inches="tight", facecolor="white")
    plt.close(fig)
    print("đã vẽ", name)


def legend_sites(ax, x, y, keys=("S0", "S1", "S2", "S3"), dx=2.6):
    for i, k in enumerate(keys):
        ec, fc, label = SITE[k]
        ax.add_patch(Rectangle((x + i * dx, y - 0.15), 0.3, 0.3, ec=ec, fc=fc, lw=1.5))
        ax.text(x + i * dx + 0.42, y, label, va="center", fontsize=9.5, color=INK)


# ------------------------------------------------------------------ 1. Cây HV – KhachHang
def cay_hv():
    fig, ax = canvas(13, 6.4, (0, 18), (0, 9))
    box(ax, 9, 8.1, 3.2, 0.8, "KhachHang", *ROOT, size=13, weight="bold")
    xs = [3, 9, 15]
    for i, x in enumerate(xs, 1):
        arrow(ax, 9, 7.7, x, 6.15, f"σ MaCN='CN0{i}'", color=SIGMA[0], size=10)
        box(ax, x, 5.75, 2.4, 0.8, f"KH{'₁₂₃'[i-1]}", *SIGMA, size=12, weight="bold")
        for dx, kind, site, cols in [(-1.45, "GD", f"S{i}", "MaKH, HoTen, SDT,\nEmail, DiaChi, MaCN"),
                                     (1.45, "TC", "S0", "MaKH, HanMucNo,\nCongNo, DiemTichLuy")]:
            ec, fc, _ = SITE[site]
            arrow(ax, x, 5.35, x + dx, 3.75, "π", color=PI[0], size=11)
            box(ax, x + dx, 2.75, 2.7, 1.9, f"KH{'₁₂₃'[i-1]}_{kind}\n{cols}\n@ {site}", ec, fc, size=9.5, lw=2)
    ax.text(9, 0.75, "KhachHang = ⋃ᵢ ( KHᵢ_GD ⋈_MaKH KHᵢ_TC )", ha="center", fontsize=12.5, color=INK)
    ax.text(0.2, 8.6, "Phân mảnh hỗn hợp HV (ngang → dọc)", fontsize=12, weight="bold", color=INK)
    legend_sites(ax, 7.2, 0.15, dx=2.7)
    save(fig, "cay_HV_KhachHang")


# ------------------------------------------------------------------ 2. Cây VH – NhanVien
def cay_vh():
    fig, ax = canvas(12, 6.4, (0, 16.5), (0, 9))
    box(ax, 8.25, 8.1, 3.2, 0.8, "NhanVien", *ROOT, size=13, weight="bold")
    # nhánh công việc
    arrow(ax, 8.25, 7.7, 5, 6.25, "π", color=PI[0], size=11)
    box(ax, 5, 5.7, 4.2, 1.0, "NV_CV\nMaNV, HoTen, ChucVu, SDT, MaCN", *PI, size=10, weight="bold")
    # nhánh nhân sự (lá)
    ec, fc, _ = SITE["S0"]
    arrow(ax, 8.25, 7.7, 12.6, 6.4, "π", color=PI[0], size=11)
    box(ax, 12.6, 5.6, 4.0, 1.5, "NV_NS\nMaNV, NgaySinh, CCCD,\nLuong, SoTaiKhoan\n@ S0", ec, fc, size=10, lw=2)
    for i, x in enumerate([1.6, 5, 8.4], 1):
        ec, fc, _ = SITE[f"S{i}"]
        arrow(ax, 5, 5.2, x, 3.65, "σ", color=SIGMA[0], size=11)
        box(ax, x, 2.95, 3.1, 1.25, f"NV_CV{'₁₂₃'[i-1]}\nσ MaCN='CN0{i}'(NV_CV)\n@ S{i}", ec, fc, size=9.5, lw=2)
    ax.text(12.6, 3.6, "Dữ liệu nhạy cảm: không chia\ntheo chi nhánh (và không có MaCN)", ha="center",
            fontsize=9.5, color="#6B7280", style="italic")
    ax.text(8.25, 1.25, "NhanVien = ( NV_CV₁ ∪ NV_CV₂ ∪ NV_CV₃ ) ⋈_MaNV NV_NS", ha="center", fontsize=12.5, color=INK)
    ax.text(0.2, 8.6, "Phân mảnh hỗn hợp VH (dọc → ngang)", fontsize=12, weight="bold", color=INK)
    legend_sites(ax, 5.2, 0.35, dx=2.7)
    save(fig, "cay_VH_NhanVien")


# ------------------------------------------------------------------ 3. Cấp phát 4 site
def cap_phat():
    fig, ax = canvas(12, 7.4, (0, 16), (0, 10))
    ax.add_patch(Ellipse((8, 5.45), 4.2, 1.5, ec="#9CA3AF", fc="#F3F4F6", lw=1.4, ls="--"))
    ax.text(8, 5.45, "Mạng", ha="center", va="center", fontsize=12, color="#6B7280")
    frag = {
        "S0": "KH₁_TC · KH₂_TC · KH₃_TC\nNV_NS",
        "S1": "KH₁_GD · NV_CV₁\nDH₁ · CTDH₁",
        "S2": "KH₂_GD · NV_CV₂\nDH₂ · CTDH₂",
        "S3": "KH₃_GD · NV_CV₃\nDH₃ · CTDH₃",
    }
    pos = {"S0": (8, 8.5), "S1": (2.8, 2.2), "S2": (8, 1.6), "S3": (13.2, 2.2)}
    for k, (x, y) in pos.items():
        ec, fc, label = SITE[k]
        ax.plot([x, 8], [y, 5.45], color="#9CA3AF", lw=1.3, zorder=0)
        ax.add_patch(FancyBboxPatch((x - 2.25, y - 1.15), 4.5, 2.3, boxstyle="round,pad=0.02,rounding_size=0.15",
                                    ec=ec, fc=fc, lw=2.2, zorder=1))
        ax.text(x, y + 0.75, label, ha="center", va="center", fontsize=12, weight="bold", color=ec, zorder=2)
        ax.text(x, y + 0.02, frag[k], ha="center", va="center", fontsize=10.5, color=INK, linespacing=1.4, zorder=2)
        ax.text(x, y - 0.8, "nhân bản: ChiNhanh, SanPham", ha="center", va="center", fontsize=8.8,
                color="#6B7280", style="italic", zorder=2)
    ax.text(0.2, 9.75, "Lược đồ cấp phát", fontsize=12, weight="bold", color=INK)
    save(fig, "cap_phat_4_site")


# ------------------------------------------------------------------ 4. Kiến trúc CSDL phân tán
def kien_truc():
    fig, ax = canvas(10, 6.4, (0, 14), (0, 9))
    box(ax, 7, 8.2, 4.6, 0.8, "Người dùng / Ứng dụng", "#374151", "#F9FAFB", size=11.5, weight="bold")
    box(ax, 7, 6.85, 8.5, 0.9, "Hệ quản trị CSDL phân tán (DDBMS)\nnhìn thấy một CSDL logic duy nhất", "#7C3AED", "#EDE9FE", size=10.5)
    arrow(ax, 7, 7.8, 7, 7.3, color="#374151", both=True)
    ax.add_patch(Ellipse((7, 4.3), 3.6, 1.3, ec="#9CA3AF", fc="#F3F4F6", lw=1.4, ls="--"))
    ax.text(7, 4.3, "Mạng máy tính", ha="center", va="center", fontsize=11, color="#6B7280")
    arrow(ax, 7, 6.4, 7, 4.95, color="#7C3AED")
    pos = {"S0": (2, 5.2), "S1": (2.2, 1.6), "S2": (7, 1.2), "S3": (11.8, 1.6)}
    pos["S0"] = (11.8, 5.0)
    for k, (x, y) in pos.items():
        ec, fc, label = SITE[k]
        ax.plot([x, 7], [y, 4.3], color="#9CA3AF", lw=1.3, zorder=0)
        box(ax, x, y, 3.2, 1.2, f"{label}\nDBMS + CSDL cục bộ", ec, fc, size=10, lw=2)
    save(fig, "kien_truc_CSDLPT")


# ------------------------------------------------------------------ 5. Các mức lược đồ
def muc_luoc_do():
    fig, ax = canvas(8, 7.0, (0, 10), (1.5, 11.8))
    levels = [
        ("Lược đồ toàn cục", "định nghĩa các quan hệ như với CSDL tập trung", "#111827", "#F9FAFB"),
        ("Lược đồ phân mảnh", "chia mỗi quan hệ thành các mảnh (σ, π)", SIGMA[0], SIGMA[1]),
        ("Lược đồ cấp phát", "đặt mỗi mảnh lên một hoặc nhiều site", "#2563EB", "#DBEAFE"),
    ]
    y = 11
    for title, desc, ec, fc in levels:
        box(ax, 5, y, 7.4, 1.25, f"{title}\n{desc}", ec, fc, size=10.5, lw=1.8)
        arrow(ax, 5, y - 0.65, 5, y - 1.55, color="#6B7280")
        y -= 2.2
    ax.text(5.25, y + 1.0, "↑ độc lập với vị trí\n↓ phụ thuộc vị trí", ha="left", va="center", fontsize=9, color="#6B7280", style="italic")
    for i, x in enumerate([2.0, 5, 8]):
        box(ax, x, y - 0.25, 2.6, 1.15, f"Lược đồ ánh xạ\ncục bộ {i + 1}", "#4B5563", "#E5E7EB", size=9.5)
        arrow(ax, x, y - 0.85, x, y - 1.55, color="#6B7280")
        box(ax, x, y - 2.15, 2.6, 1.1, f"DBMS + CSDL\ncục bộ site {i + 1}", "#4B5563", "#F3F4F6", size=9.5)
    save(fig, "muc_luoc_do_CSDLPT")


# ------------------------------------------------------------------ 6. Lược đồ quan hệ toàn cục
def luoc_do_quan_he():
    tables = {
        "NhanVien": (["MaNV", "HoTen", "ChucVu", "SDT", "MaCN", "NgaySinh", "CCCD", "Luong", "SoTaiKhoan"], (2.2, 11)),
        "ChiNhanh": (["MaCN", "TenCN", "KhuVuc", "DiaChi", "SDT"], (7.4, 11)),
        "KhachHang": (["MaKH", "HoTen", "SDT", "Email", "DiaChi", "MaCN", "HanMucNo", "CongNo", "DiemTichLuy"], (12.6, 11)),
        "DonHang": (["MaDH", "NgayDat", "MaKH", "MaNV", "TrangThai", "TongTien"], (7.4, 5.4)),
        "ChiTietDonHang": (["MaDH", "MaSP", "SoLuong", "DonGia"], (12.6, 4.8)),
        "SanPham": (["MaSP", "TenSP", "DonViTinh", "GiaBan", "MoTa"], (17.8, 4.8)),
    }
    pk = {"ChiNhanh": {"MaCN"}, "KhachHang": {"MaKH"}, "NhanVien": {"MaNV"}, "DonHang": {"MaDH"},
          "ChiTietDonHang": {"MaDH", "MaSP"}, "SanPham": {"MaSP"}}
    fig, ax = canvas(14, 7.6, (0.4, 19.6), (0.2, 11.2))
    w, rh = 3.2, 0.42
    anchor = {}
    for name, (cols, (x, top)) in tables.items():
        ax.add_patch(Rectangle((x - w / 2, top - rh), w, rh, fc="#1F2937", ec="#1F2937"))
        ax.text(x, top - rh / 2, name, ha="center", va="center", color="white", fontsize=10.5, weight="bold")
        for j, c in enumerate(cols):
            y = top - rh * (j + 2)
            ax.add_patch(Rectangle((x - w / 2, y), w, rh, fc="#FFFFFF" if j % 2 else "#F9FAFB", ec="#D1D5DB", lw=0.8))
            ax.text(x - w / 2 + 0.15, y + rh / 2, ("PK  " if c in pk[name] else "      ") + c, va="center",
                    fontsize=9.5, color=INK, weight="bold" if c in pk[name] else "normal")
            anchor[(name, c)] = (x, y + rh / 2)
    def fk(src, col, dst, dcol, rad=0.0):
        (x1, y1), (x2, y2) = anchor[(src, col)], anchor[(dst, dcol)]
        side1 = -1 if x2 < x1 else 1
        side2 = -side1
        ax.annotate("", xy=(x2 + side2 * w / 2, y2), xytext=(x1 + side1 * w / 2, y1),
                    arrowprops=dict(arrowstyle="-|>", color="#6B7280", lw=1.2, connectionstyle=f"arc3,rad={rad}"))
    fk("NhanVien", "MaCN", "ChiNhanh", "MaCN", 0.15)
    fk("KhachHang", "MaCN", "ChiNhanh", "MaCN", -0.15)
    def fk_day(src, col, dst, dx):
        x1, y1 = anchor[(src, col)]
        cols, (x2, top) = tables[dst]
        side = -1 if x2 < x1 else 1
        ax.annotate("", xy=(x2 + dx, top - rh * (len(cols) + 1)), xytext=(x1 + side * w / 2, y1),
                    arrowprops=dict(arrowstyle="-|>", color="#6B7280", lw=1.2))
    fk_day("DonHang", "MaNV", "NhanVien", 0.7)     # trỏ vào đáy bảng NhanVien (khóa MaNV)
    fk_day("DonHang", "MaKH", "KhachHang", -0.7)   # trỏ vào đáy bảng KhachHang (khóa MaKH)
    fk("ChiTietDonHang", "MaDH", "DonHang", "MaDH", 0.0)
    fk("ChiTietDonHang", "MaSP", "SanPham", "MaSP", 0.0)
    ax.text(0.6, 0.5, "PK: khóa chính · mũi tên: khóa ngoại → bảng được tham chiếu", fontsize=9, color="#6B7280")
    save(fig, "luoc_do_quan_he")


# ------------------------------------------------------------------ 7. Minh họa 3 loại phân mảnh
def ba_loai():
    fig, axes = plt.subplots(1, 3, figsize=(13, 4.2))
    titles = ["Phân mảnh ngang (σ)", "Phân mảnh dọc (π)", "Phân mảnh hỗn hợp (σ + π)"]
    colors_row = ["#FEE2E2", "#DCFCE7", "#DBEAFE"]
    nrow, ncol = 6, 6
    for k, ax in enumerate(axes):
        ax.set_xlim(-0.3, ncol + 0.3)
        ax.set_ylim(-1.2, nrow + 0.6)
        ax.axis("off")
        ax.set_title(titles[k], fontsize=12.5, weight="bold", color=INK)
        for r in range(nrow):
            for c in range(ncol):
                if k == 0:
                    fc = colors_row[r // 2]
                elif k == 1:
                    fc = "#EDE9FE" if c < 3 else "#FEF3C7"
                else:
                    fc = colors_row[r // 2] if c < 3 else "#E5E7EB"
                if c == 0 and k != 0:
                    fc = "#C7D2FE"  # khóa lặp lại ở mọi mảnh dọc
                ax.add_patch(Rectangle((c, nrow - 1 - r), 1, 1, fc=fc, ec="white", lw=1.5))
        if k in (0, 2):
            for cut in (2, 4):
                ax.plot([-0.2, ncol + 0.2], [cut, cut], color="#111827", lw=2.2)
        if k in (1, 2):
            ax.plot([3, 3], [-0.2, nrow + 0.2], color="#111827", lw=2.2)
        cap = ["mỗi mảnh: một tập dòng\ntái thiết bằng ∪",
               "mỗi mảnh: một tập cột + khóa\ntái thiết bằng ⋈ trên khóa",
               "mỗi mảnh: một ô dòng × cột\ntái thiết bằng ∪ và ⋈"][k]
        ax.text(ncol / 2, -0.75, cap, ha="center", va="center", fontsize=10.5, color=INK)
    fig.tight_layout()
    save(fig, "ba_loai_phan_manh")


# ------------------------------------------------------------------ 8. Ma trận sử dụng KhachHang
def ma_tran():
    attrs = ["MaKH", "HoTen", "SDT", "Email", "DiaChi", "MaCN", "HanMucNo", "CongNo", "DiemTichLuy"]
    use = {"Q1": [1, 1, 1, 1, 1, 1, 0, 0, 0], "Q2": [1, 1, 0, 0, 1, 1, 0, 0, 0], "Q3": [1, 0, 0, 0, 0, 1, 1, 1, 1]}
    fig, ax = canvas(11, 3.4, (-1.6, 9.2), (-1.3, 3.9))
    for j, a in enumerate(attrs):
        ax.text(j + 0.5, 3.2, a, ha="center", va="center", fontsize=9 if len(a) >= 8 else 10, weight="bold")
    for i, (q, row) in enumerate(use.items()):
        y = 2 - i
        ax.text(-0.3, y + 0.5, q, ha="right", va="center", fontsize=11, weight="bold")
        for j, v in enumerate(row):
            grp = "GD" if j <= 5 else "TC"
            fc = ("#FEE2E2" if grp == "GD" else "#E5E7EB") if v else "white"
            ax.add_patch(Rectangle((j, y), 1, 1, fc=fc, ec="#D1D5DB", lw=1))
            ax.text(j + 0.5, y + 0.5, str(v), ha="center", va="center", fontsize=11, color=INK if v else "#9CA3AF")
    ax.plot([6, 6], [-0.1, 3.0], color="#111827", lw=2.2)
    ax.text(3, -0.55, "Nhóm GIAO DỊCH → đặt tại chi nhánh (Q1, Q2)", ha="center", fontsize=10.5, color="#DC2626", weight="bold")
    ax.text(7.5, -0.55, "Nhóm TÀI CHÍNH → trụ sở (Q3)", ha="center", fontsize=10.5, color="#4B5563", weight="bold")
    ax.text(4.5, -1.1, "MaKH lặp lại ở cả hai nhóm (khóa); MaCN dùng cho cả phân mảnh ngang", ha="center", fontsize=9, color="#6B7280", style="italic")
    save(fig, "ma_tran_su_dung_KhachHang")


# ------------------------------------------------------------------ 9. Chuỗi phân mảnh dẫn xuất
def dan_xuat():
    fig, ax = canvas(10, 2.0, (0, 14), (0, 2.6))
    items = [("KHᵢ\nσ MaCN='CN0i'(KhachHang)", 2.2), ("DHᵢ\nDonHang ⋉_MaKH KHᵢ", 7), ("CTDHᵢ\nChiTietDonHang ⋉_MaDH DHᵢ", 11.8)]
    for t, x in items:
        box(ax, x, 1.3, 3.9, 1.3, t, SIGMA[0], SIGMA[1], size=10.5)
    arrow(ax, 4.15, 1.3, 5.05, 1.3, color="#6B7280")
    arrow(ax, 8.95, 1.3, 9.85, 1.3, color="#6B7280")
    ax.text(7, 0.15, "cùng đặt tại site Sᵢ → phép kết nối KhachHang ⋈ DonHang ⋈ ChiTietDonHang chạy cục bộ",
            ha="center", fontsize=9.5, color="#6B7280", style="italic")
    save(fig, "phan_manh_dan_xuat")


if __name__ == "__main__":
    cay_hv()
    cay_vh()
    cap_phat()
    kien_truc()
    muc_luoc_do()
    luoc_do_quan_he()
    ba_loai()
    ma_tran()
    dan_xuat()
