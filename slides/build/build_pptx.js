// Dựng file slide từ slides/noi_dung_slide.md (lời thuyết trình → Notes) và assets/diagrams/.
//   cd slides/build && node build_pptx.js   → slides/Slide_PhanManhHonHop.pptx
//
// Trong chuỗi chữ trên slide: **đậm**, $công thức$ (font Cambria Math, X_{...} là chỉ số dưới).
const fs = require("fs");
const path = require("path");
const pptxgen = require("pptxgenjs");
const React = require("react");
const ReactDOMServer = require("react-dom/server");
const sharp = require("sharp");
const fa = require("react-icons/fa6");
const { applyTheme } = require(path.join(process.env.USERPROFILE,
  ".claude/skills/synced/5cb8ee69-95c3-4293-ab5a-6d7e85160de0_d3ffd09b-d7dd-4467-9dbf-2c3029683630/pptx/scripts/apply_theme.js"));

const ROOT = path.resolve(__dirname, "..", "..");
const DIAG = (f) => path.join(ROOT, "assets", "diagrams", f);
const OUT = path.join(ROOT, "slides", "Slide_PhanManhHonHop.pptx");
const MATH = "Cambria Math";

// Màu khớp với sơ đồ trong assets/diagrams: σ cam, π tím, S0 xám, S1 đỏ, S2 xanh lá, S3 xanh dương
const THEME = {
  name: "PhanManhHonHop",
  headFontFace: "Cambria",
  bodyFontFace: "Calibri",
  colors: {
    dk1: "1F2937", lt1: "FFFFFF", dk2: "4B5563", lt2: "F3F4F6",
    accent1: "D97706", accent2: "7C3AED", accent3: "DC2626", accent4: "16A34A",
    accent5: "2563EB", accent6: "4B5563", hlink: "2563EB", folHlink: "7C3AED",
  },
};
const HEX = THEME.colors;
const TINT = { amber: "FEF3C7", purple: "EDE9FE", red: "FEE2E2", green: "DCFCE7", blue: "DBEAFE", gray: "E5E7EB" };

// ------------------------------------------------------------------ lời thuyết trình
function readNotes() {
  const md = fs.readFileSync(path.join(ROOT, "slides", "noi_dung_slide.md"), "utf8");
  const notes = {};
  for (const block of md.split(/\n## Slide /).slice(1)) {
    const n = parseInt(block, 10);
    const head = block.split("\n")[0];
    const who = (head.match(/\*([^*]+)\*\s*$/) || [, ""])[1];
    const talk = block.split("**Lời thuyết trình**")[1] || "";
    const paras = talk.split("\n").filter((l) => l.startsWith("> ")).map((l) => l.slice(2).trim());
    notes[n] = `[${who}]\n\n` + paras.join("\n\n");
  }
  return notes;
}
const NOTES = readNotes();

// ------------------------------------------------------------------ chữ có công thức
// Trả về mảng run cho addText. opts áp dụng cho mọi run; paraOpts chỉ cho run đầu đoạn.
function runs(str, opts = {}) {
  const out = [];
  str.split("$").forEach((seg, i) => {
    if (!seg) return;
    if (i % 2 === 1) {
      const re = /_\{([^}]*)\}/g;
      let last = 0, m;
      while ((m = re.exec(seg))) {
        if (m.index > last) out.push({ text: seg.slice(last, m.index), options: { ...opts, fontFace: MATH } });
        out.push({ text: m[1], options: { ...opts, fontFace: MATH, subscript: true } });
        last = m.index + m[0].length;
      }
      if (last < seg.length) out.push({ text: seg.slice(last), options: { ...opts, fontFace: MATH } });
    } else {
      seg.split("**").forEach((t, j) => {
        if (t) out.push({ text: t, options: { ...opts, ...(j % 2 ? { bold: true } : {}) } });
      });
    }
  });
  return out;
}
// Ghép nhiều đoạn thành một khối chữ; mỗi đoạn là chuỗi hoặc { t, bullet, indent, size, color, bold, space }
function paras(list, base = {}) {
  const out = [];
  list.forEach((p, k) => {
    const o = typeof p === "string" ? { t: p } : p;
    const rs = runs(o.t, { ...base, ...(o.size ? { fontSize: o.size } : {}), ...(o.color ? { color: o.color } : {}),
      ...(o.bold ? { bold: true } : {}), ...(o.italic ? { italic: true } : {}) });
    rs[0].options = { ...rs[0].options, paraSpaceAfter: o.space ?? 8,
      ...(o.bullet ? { bullet: o.indent ? { indent: 18 } : { indent: 18 }, indentLevel: o.indent ? 1 : 0 } : {}) };
    if (k < list.length - 1) rs[rs.length - 1].options = { ...rs[rs.length - 1].options, breakLine: true };
    out.push(...rs);
  });
  return out;
}

// ------------------------------------------------------------------ icon
async function icon(name, color) {
  const svg = ReactDOMServer.renderToStaticMarkup(React.createElement(fa[name], { color: "#" + color, size: 256 }));
  const buf = await sharp(Buffer.from(svg)).png().toBuffer();
  return "image/png;base64," + buf.toString("base64");
}

async function main() {
  const pres = new pptxgen();
  pres.layout = "LAYOUT_WIDE"; // 13.333 × 7.5 in
  pres.theme = { headFontFace: THEME.headFontFace, bodyFontFace: THEME.bodyFontFace };
  pres.title = "Phân mảnh hỗn hợp trong CSDL phân tán";
  pres.author = "Trần Gia Thịnh, Phạm Minh Triết";
  pres.subject = "Đồ án Cơ Sở Dữ Liệu Nâng Cao";
  const C = pres.SchemeColor;
  const W = 13.333, M = 0.6, CW = W - 2 * M;

  // ---------------------------------------------------------------- layouts
  pres.defineSlideMaster({
    title: "TOI", background: { color: C.text1 },
    objects: [],
  });
  pres.defineSlideMaster({
    title: "NOI_DUNG", background: { color: C.background1 },
    margin: [0.5, M, 0.6, M],
    objects: [
      { placeholder: { options: { name: "kicker", type: "body", x: M, y: 0.32, w: 9, h: 0.34, fontSize: 13, bold: true,
        color: C.accent1, margin: 0, valign: "middle" }, text: "" } },
      { placeholder: { options: { name: "title", type: "title", x: M, y: 0.66, w: CW, h: 0.8, fontSize: 32, bold: true,
        color: C.text1, fontFace: THEME.headFontFace, margin: 0, valign: "middle", align: "left" }, text: "" } },
      { text: { text: "Phân mảnh hỗn hợp trong CSDL phân tán · Cơ Sở Dữ Liệu Nâng Cao",
        options: { x: M, y: 7.02, w: 8, h: 0.3, fontSize: 10, color: C.text2, margin: 0, valign: "middle" } } },
    ],
    slideNumber: { x: W - M - 0.6, y: 7.02, w: 0.6, h: 0.3, fontSize: 10, color: C.text2, align: "right", margin: 0 },
  });

  let n = 0, curSection = null;
  const section = (title) => {
    if (title !== curSection) pres.addSection({ title });
    curSection = title;
  };
  const content = (sec, kicker, title) => {
    n++;
    section(sec);
    const s = pres.addSlide({ masterName: "NOI_DUNG", sectionTitle: sec });
    s.addText(kicker, { placeholder: "kicker" });
    s.addText(title, { placeholder: "title" });
    s.addNotes(NOTES[n]);
    return s;
  };
  const dark = (sec) => {
    n++;
    section(sec);
    const s = pres.addSlide({ masterName: "TOI", sectionTitle: sec });
    s.addNotes(NOTES[n]);
    return s;
  };

  // ---------------------------------------------------------------- khối dựng sẵn
  const card = (s, x, y, w, h, fill, name, extra = {}) =>
    s.addShape(pres.shapes.ROUNDED_RECTANGLE, { x, y, w, h, rectRadius: 0.12, fill: { color: fill },
      line: { color: fill, width: 0 }, objectName: name, ...extra });
  const text = (s, t, o) => s.addText(Array.isArray(t) ? t : runs(t), { isTextBox: true, margin: 0, valign: "top",
    fontSize: 16, color: C.text1, ...o });
  const iconDot = async (s, name, x, y, d, fill, fg = HEX.lt1) => {
    s.addShape(pres.shapes.OVAL, { x, y, w: d, h: d, fill: { color: fill }, line: { color: fill, width: 0 }, objectName: "icon-nen" });
    s.addImage({ data: await icon(name, fg), x: x + d * 0.25, y: y + d * 0.25, w: d * 0.5, h: d * 0.5, altText: name });
  };
  const image = (s, file, x, y, w, ratio, alt) => s.addImage({ path: DIAG(file), x, y, w, h: w / ratio, altText: alt });
  // Lưới mảnh KhachHang (motif của bìa và trang cuối): 3 chi nhánh × {GD, TC}
  const grid = (s, x, y) => {
    const cw = 1.6, ch = 0.95, g = 0.18;
    [["Giao dịch", 0], ["Tài chính", 1]].forEach(([t, j]) =>
      text(s, t, { x: x + j * (cw + g), y: y - 0.42, w: cw, h: 0.3, fontSize: 13, color: "D1D5DB", align: "center" }));
    [[C.accent3, "1"], [C.accent4, "2"], [C.accent5, "3"]].forEach(([col, i], r) => {
      [[col, `KH${"₁₂₃"[r]}_GD`], [C.accent6, `KH${"₁₂₃"[r]}_TC`]].forEach(([fill, label], j) => {
        card(s, x + j * (cw + g), y + r * (ch + g), cw, ch, fill, "o-manh");
        text(s, label, { x: x + j * (cw + g), y: y + r * (ch + g), w: cw, h: ch, fontSize: 16, bold: true,
          color: C.background1, align: "center", valign: "middle" });
      });
    });
  };

  // ================================================================ 1. Bìa
  {
    const s = dark("Mở đầu");
    text(s, "TRƯỜNG ĐẠI HỌC CÔNG NGHỆ TP.HCM · KHOA CÔNG NGHỆ THÔNG TIN",
      { x: M + 0.1, y: 0.6, w: 8.4, h: 0.35, fontSize: 13, color: "D1D5DB", charSpacing: 1 });
    // logo HUTECH (chữ xanh) đặt trên khung trắng để nổi trên nền tối
    {
      const logo = path.join(ROOT, "assets", "logo_hutech.png"), b = fs.readFileSync(logo);
      // khung phải kết thúc trên nhãn "Giao dịch / Tài chính" của grid (y ≈ 1.48)
      const lw = 2.6, lh = lw * b.readUInt32BE(20) / b.readUInt32BE(16), bx = W - M - 2.9, by = 0.3;
      card(s, bx, by, 2.9, lh + 0.3, C.background1, "nen-logo");
      s.addImage({ path: logo, x: bx + 0.15, y: by + 0.15, w: lw, h: lh, objectName: "logo-hutech" });
    }
    text(s, "Môn: Cơ Sở Dữ Liệu Nâng Cao", { x: M + 0.1, y: 1.0, w: 8, h: 0.4, fontSize: 18, bold: true, color: C.accent1 });
    text(s, "TÌM HIỂU PHÂN MẢNH HỖN HỢP TRONG CSDL PHÂN TÁN VÀ ỨNG DỤNG CHO QUẢN LÝ ĐƠN HÀNG",
      { x: M + 0.1, y: 1.8, w: 7.7, h: 2.7, fontSize: 34, bold: true, fontFace: THEME.headFontFace,
        color: C.background1, valign: "middle", lineSpacingMultiple: 1.05 });
    text(s, paras([{ t: "Giảng viên hướng dẫn", size: 13, color: "D1D5DB", space: 4 },
      { t: "ThS. Nguyễn Văn Danh", size: 20, bold: true }], { color: C.background1 }),
      { x: M + 0.1, y: 5.25, w: 3.4, h: 1.2 });
    text(s, paras([{ t: "Nhóm thực hiện · Lớp 23DTHE3", size: 13, color: "D1D5DB", space: 4 },
      { t: "Trần Gia Thịnh – 2380602136", size: 18, space: 2 }, { t: "Phạm Minh Triết – 2380605829", size: 18 }],
      { color: C.background1 }), { x: 4.3, y: 5.25, w: 4.6, h: 1.4 });
    grid(s, 9.25, 1.9);
  }

  // ================================================================ 2. Nội dung trình bày
  {
    const s = content("Mở đầu", "MỞ ĐẦU", "Nội dung trình bày");
    const items = [["Tổng quan CSDL phân tán", "Thịnh"], ["Phân mảnh dữ liệu: ngang và dọc", "Thịnh"],
      ["Phân mảnh hỗn hợp", "Thịnh"], ["Ứng dụng cho hệ thống quản lý đơn hàng + demo", "Triết"],
      ["Đánh giá và kết luận", "Triết"]];
    const g = 0.25, w = (CW - 4 * g) / 5;
    items.forEach(([t, who], i) => {
      const x = M + i * (w + g), hot = i === 2 || i === 3;
      card(s, x, 1.95, w, 3.9, hot ? C.text1 : C.background2, "the-muc");
      text(s, String(i + 1), { x: x + 0.3, y: 2.2, w: 1, h: 0.9, fontSize: 48, bold: true,
        fontFace: THEME.headFontFace, color: C.accent1 });
      text(s, t, { x: x + 0.3, y: 3.25, w: w - 0.5, h: 1.7, fontSize: 19, bold: true,
        color: hot ? C.background1 : C.text1 });
      text(s, who, { x: x + 0.3, y: 5.3, w: w - 0.5, h: 0.35, fontSize: 13, color: hot ? "D1D5DB" : C.text2 });
    });
    text(s, "Trọng tâm: phần 3 (lý thuyết) và phần 4 (ứng dụng + demo trên SQL Server)",
      { x: M, y: 6.2, w: CW, h: 0.4, fontSize: 15, italic: true, color: C.text2 });
  }

  // ================================================================ 3. CSDL phân tán
  {
    const s = content("Lý thuyết", "1 · TỔNG QUAN CSDL PHÂN TÁN", "CSDL phân tán là gì?");
    const rows = [
      ["FaDatabase", "Thống nhất về logic, phân tán về vật lý", "Dữ liệu nằm ở nhiều site, nối với nhau qua mạng"],
      ["FaEyeSlash", "DDBMS che giấu sự phân tán", "Người dùng thấy như một CSDL duy nhất (tính trong suốt)"],
      ["FaLocationDot", "Lợi ích", "Dữ liệu gần nơi sử dụng, tăng độ sẵn sàng, dễ mở rộng, hợp với tổ chức nhiều chi nhánh"],
      ["FaPuzzlePiece", "Hai bài toán thiết kế", "**Phân mảnh**: chia dữ liệu thế nào? · **Cấp phát**: đặt mảnh ở đâu?"],
    ];
    for (const [k, [ic, h, d]] of rows.entries()) {
      const y = 1.8 + k * 1.22;
      await iconDot(s, ic, M, y, 0.62, k === 3 ? C.accent1 : C.text1);
      text(s, paras([{ t: h, bold: true, size: 18, space: 3 }, { t: d, size: 15, color: C.text2 }]),
        { x: M + 0.85, y: y - 0.04, w: 5.4, h: 1.1 });
    }
    image(s, "kien_truc_CSDLPT.png", 7.05, 1.7, 5.7, 1590 / 1025, "Kiến trúc CSDL phân tán gồm 4 site nối qua mạng");
  }

  // ================================================================ 4. Vì sao phân mảnh
  {
    const s = content("Lý thuyết", "2 · PHÂN MẢNH DỮ LIỆU", "Vì sao phải phân mảnh?");
    text(s, paras([
      { t: "Ứng dụng thường chỉ dùng **một phần** của bảng: một số dòng, một số cột.", space: 4 },
      { t: "Đặt nguyên bảng ở một nơi thì truy cập từ xa nhiều; nhân bản nguyên bảng thì tốn chỗ và khó cập nhật.", color: C.text2 },
    ], { fontSize: 17 }), { x: M, y: 1.7, w: CW, h: 0.9 });
    const benefits = [["FaLocationDot", "Xử lý cục bộ"], ["FaServer", "Xử lý song song"], ["FaShieldHalved", "Bảo mật dữ liệu nhạy cảm"]];
    const w = (CW - 2 * 0.3) / 3;
    for (const [i, [ic, t]] of benefits.entries()) {
      const x = M + i * (w + 0.3);
      card(s, x, 2.85, w, 0.95, C.background2, "loi-ich");
      await iconDot(s, ic, x + 0.22, 3.0, 0.65, C.text1);
      text(s, t, { x: x + 1.05, y: 2.85, w: w - 1.2, h: 0.95, fontSize: 18, bold: true, valign: "middle" });
    }
    text(s, "3 QUY TẮC ĐÚNG ĐẮN", { x: M, y: 4.1, w: 6, h: 0.35, fontSize: 14, bold: true, color: C.accent1, charSpacing: 1 });
    const rules = [["Đầy đủ", "Mọi dữ liệu của R đều nằm trong ít nhất một mảnh", TINT.amber],
      ["Tái thiết", "Ghép các mảnh lại được đúng R", TINT.purple],
      ["Rời nhau", "Một dữ liệu không nằm ở hai mảnh (phân mảnh dọc được lặp lại khóa)", TINT.gray]];
    rules.forEach(([h, d, tint], i) => {
      const x = M + i * (w + 0.3);
      card(s, x, 4.55, w, 1.75, tint, "quy-tac");
      text(s, paras([{ t: h, bold: true, size: 21, space: 6 }, { t: d, size: 16 }]), { x: x + 0.3, y: 4.8, w: w - 0.6, h: 1.65 });
    });
  }

  // ================================================================ 5. Phân mảnh ngang
  {
    const s = content("Lý thuyết", "2 · PHÂN MẢNH DỮ LIỆU", "Phân mảnh ngang");
    text(s, paras([
      { t: "Chia bảng theo **dòng**, dựa trên vị từ chọn: $Rᵢ = σ_{Fᵢ}(R)$", bullet: true },
      { t: "Ví dụ: $KH₁ = σ_{MaCN='CN01'}(KhachHang)$, tương tự KH₂, KH₃", bullet: true },
      { t: "Thiết kế: vị từ đơn giản từ truy vấn → **vị từ hội sơ cấp (minterm)**; thuật toán **COM_MIN** chọn tập vị từ đầy đủ và cực tiểu", bullet: true },
      { t: "**Ngang dẫn xuất:** chia bảng con theo mảnh của bảng cha: $DHᵢ = DonHang ⋉ KHᵢ$", bullet: true },
      { t: "Tái thiết: $R = R₁ ∪ R₂ ∪ … ∪ Rₙ$", bullet: true },
    ], { fontSize: 17 }), { x: M, y: 1.75, w: 6.2, h: 4.9 });
    // bảng KhachHang tô màu theo chi nhánh → 3 mảnh
    const rowsKH = [["KH01", "An", "CN01", 0], ["KH02", "Bình", "CN02", 1], ["KH03", "Chi", "CN03", 2],
      ["KH04", "Dũng", "CN01", 0], ["KH05", "Em", "CN02", 1], ["KH06", "Giang", "CN03", 2]];
    const tints = [TINT.red, TINT.green, TINT.blue], cols = [C.accent3, C.accent4, C.accent5];
    const hdr = (t) => ({ text: t, options: { bold: true, color: HEX.lt1, fill: { color: HEX.dk1 } } });
    s.addTable([[hdr("MaKH"), hdr("HoTen"), hdr("MaCN")],
      ...rowsKH.map(([a, b, c, k]) => [a, b, c].map((t) => ({ text: t, options: { fill: { color: tints[k] } } })))],
    { x: 7.2, y: 2.4, w: 3.2, colW: [1.0, 1.2, 1.0], rowH: 0.38, fontSize: 14, color: HEX.dk1, margin: 0.06,
      border: { type: "solid", pt: 1, color: "FFFFFF" }, valign: "middle" });
    text(s, "KhachHang", { x: 7.2, y: 5.15, w: 3.2, h: 0.3, fontSize: 13, color: C.text2, align: "center" });
    s.addShape(pres.shapes.RIGHT_ARROW, { x: 10.55, y: 3.55, w: 0.55, h: 0.45, fill: { color: C.accent1 }, line: { color: HEX.accent1, width: 0 }, objectName: "mui-ten" });
    ["KH₁ · Hà Nội", "KH₂ · Đà Nẵng", "KH₃ · TP.HCM"].forEach((t, i) => {
      card(s, 11.25, 2.45 + i * 0.85, 1.5, 0.68, cols[i], "manh-ngang");
      text(s, t, { x: 11.25, y: 2.45 + i * 0.85, w: 1.5, h: 0.68, fontSize: 14, bold: true, color: C.background1, align: "center", valign: "middle" });
    });
  }

  // ================================================================ 6. Phân mảnh dọc
  {
    const s = content("Lý thuyết", "2 · PHÂN MẢNH DỮ LIỆU", "Phân mảnh dọc");
    text(s, paras([
      { t: "Chia bảng theo **cột**: $Rᵢ = π_{Aᵢ}(R)$, mỗi mảnh **đều chứa khóa chính**", bullet: true },
      { t: "Ví dụ `NhanVien`: thông tin công việc dùng ở chi nhánh, thông tin nhân sự chỉ phòng nhân sự dùng".replace(/`/g, ""), bullet: true },
      { t: "Tái thiết bằng kết nối trên khóa: $R = R₁ ⋈_{MaNV} R₂$", bullet: true },
    ], { fontSize: 17 }), { x: M, y: 1.75, w: 5.9, h: 3.0 });
    const group = (x, title, fill, tint, colsList) => {
      card(s, x, 1.8, 2.75, 0.55, fill, "nhom-cot");
      text(s, title, { x, y: 1.8, w: 2.75, h: 0.55, fontSize: 15, bold: true, color: C.background1, align: "center", valign: "middle" });
      colsList.forEach((c, i) => {
        card(s, x, 2.45 + i * 0.47, 2.75, 0.4, i === 0 ? TINT.gray : tint, "cot");
        text(s, c, { x: x + 0.2, y: 2.45 + i * 0.47, w: 2.4, h: 0.4, fontSize: 15, bold: i === 0, valign: "middle" });
      });
    };
    group(7.0, "NV_CV · công việc", C.accent1, TINT.amber, ["MaNV (khóa)", "HoTen", "ChucVu", "SDT", "MaCN"]);
    group(10.0, "NV_NS · nhân sự", C.accent2, TINT.purple, ["MaNV (khóa)", "NgaySinh", "CCCD", "Luong", "SoTaiKhoan"]);
    text(s, "CÁCH NHÓM CỘT", { x: M, y: 5.05, w: 6, h: 0.35, fontSize: 14, bold: true, color: C.accent2, charSpacing: 1 });
    const steps = ["Ma trận sử dụng thuộc tính", "Ma trận ái lực", "BEA: gom cụm cột", "SPLIT: chọn điểm cắt"];
    const sw = 2.6, sg = (CW - 4 * sw) / 3;
    steps.forEach((t, i) => {
      const x = M + i * (sw + sg);
      card(s, x, 5.5, sw, 0.95, TINT.purple, "buoc");
      text(s, t, { x: x + 0.15, y: 5.5, w: sw - 0.3, h: 0.95, fontSize: 16, bold: true, align: "center", valign: "middle" });
      if (i < 3) s.addShape(pres.shapes.RIGHT_ARROW, { x: x + sw + (sg - 0.32) / 2, y: 5.83, w: 0.32, h: 0.3,
        fill: { color: C.accent2 }, line: { color: HEX.accent2, width: 0 }, objectName: "mui-ten" });
    });
  }

  // ================================================================ 7. Phân mảnh hỗn hợp
  {
    const s = content("Lý thuyết", "3 · PHÂN MẢNH HỖN HỢP", "Phân mảnh hỗn hợp");
    text(s, paras([
      { t: "**Kết hợp** phân mảnh ngang và dọc: áp dụng nối tiếp σ và π", bullet: true },
      { t: "Ứng dụng thực tế vừa chỉ dùng **một số dòng**, vừa chỉ dùng **một số cột**", bullet: true },
      { t: "Chi nhánh Hà Nội: chỉ **khách Hà Nội** + chỉ **cột giao dịch**", bullet: true, indent: 1, size: 16 },
      { t: "Kế toán trụ sở: **mọi khách** + chỉ **cột công nợ**", bullet: true, indent: 1, size: 16 },
      { t: "Chỉ chia ngang hoặc chỉ chia dọc → vẫn chuyển và lưu dữ liệu thừa", bullet: true },
    ], { fontSize: 17 }), { x: M, y: 1.75, w: 6.3, h: 3.6 });
    card(s, M, 5.45, 6.3, 1.1, C.text1, "cong-thuc");
    text(s, "Mảnh hỗn hợp:  $π_{A}(σ_{F}(R))$  hoặc  $σ_{F}(π_{A}(R))$",
      { x: M + 0.3, y: 5.45, w: 5.8, h: 1.1, fontSize: 22, color: C.background1, valign: "middle" });
    // lưới dòng × cột
    const gx = 8.6, gy = 2.35, cw = 2.0, ch = 1.15, g = 0.12;
    ["Giao dịch", "Tài chính"].forEach((t, j) =>
      text(s, t, { x: gx + j * (cw + g), y: gy - 0.45, w: cw, h: 0.35, fontSize: 15, bold: true, color: C.text2, align: "center" }));
    ["Hà Nội", "Đà Nẵng", "TP.HCM"].forEach((t, r) => {
      text(s, t, { x: 7.0, y: gy + r * (ch + g), w: 1.45, h: ch, fontSize: 15, bold: true, color: C.text2, align: "right", valign: "middle" });
      [0, 1].forEach((j) => {
        const hn = r === 0 && j === 0, tc = j === 1;
        card(s, gx + j * (cw + g), gy + r * (ch + g), cw, ch, hn ? C.accent3 : tc ? C.accent6 : C.background2, "o-luoi");
        if (hn || tc) text(s, hn ? "Chi nhánh Hà Nội dùng" : "Kế toán dùng", { x: gx + j * (cw + g) + 0.1, y: gy + r * (ch + g),
          w: cw - 0.2, h: ch, fontSize: 15, bold: true, color: C.background1, align: "center", valign: "middle" });
      });
    });
    text(s, "Mỗi mảnh là một ô trên lưới dòng × cột", { x: 7.0, y: 6.15, w: 5.75, h: 0.35, fontSize: 14, italic: true, color: C.text2, align: "right" });
  }

  // ================================================================ 8. HV và VH
  {
    const s = content("Lý thuyết", "3 · PHÂN MẢNH HỖN HỢP", "Hai chiến lược: HV và VH");
    const colW = 5.9;
    [[M, "HV · Ngang trước, dọc sau", C.accent1,
      ["R → σ thành R₁…Rₙ → π từng Rᵢ", "Mỗi mảnh ngang có thể chia dọc **khác nhau** · ví dụ **KhachHang**"],
      "cay_HV_KhachHang.png", 2055 / 1025, "Cây phân mảnh HV của KhachHang"],
    [M + colW + 0.33, "VH · Dọc trước, ngang sau", C.accent2,
      ["R → π thành nhóm cột → σ trên nhóm cần chia", "Chỉ chia ngang **những nhóm cột cần** · ví dụ **NhanVien**"],
      "cay_VH_NhanVien.png", 1900 / 1025, "Cây phân mảnh VH của NhanVien"],
    ].forEach(([x, h, col, lines, img, ratio, alt]) => {
      card(s, x, 1.7, colW, 0.55, col, "chien-luoc");
      text(s, h, { x: x + 0.25, y: 1.7, w: colW - 0.5, h: 0.55, fontSize: 18, bold: true, color: C.background1, valign: "middle" });
      text(s, paras(lines.map((t) => ({ t, space: 2 })), { fontSize: 15 }), { x: x + 0.1, y: 2.38, w: colW - 0.2, h: 0.8 });
      const iw = Math.min(colW, 2.95 * ratio);
      image(s, img, x + (colW - iw) / 2, 3.25, iw, ratio, alt);
    });
    text(s, "**Cây phân mảnh:** gốc là R, nút trong là σ hoặc π, **lá là mảnh được cấp phát**",
      { x: M, y: 6.35, w: CW, h: 0.4, fontSize: 16, align: "center" });
  }

  // ================================================================ 9. Tái thiết & đúng đắn
  {
    const s = content("Lý thuyết", "3 · PHÂN MẢNH HỖN HỢP", "Tái thiết và tính đúng đắn");
    text(s, "TÁI THIẾT: ĐI TỪ LÁ LÊN GỐC", { x: M, y: 1.7, w: 6, h: 0.35, fontSize: 14, bold: true, color: C.accent1, charSpacing: 1 });
    [["Nút σ  →  $∪$  (hợp)", TINT.amber], ["Nút π  →  $⋈$  trên khóa", TINT.purple]].forEach(([t, tint], i) => {
      card(s, M + i * 3.05, 2.15, 2.85, 0.9, tint, "quy-tac-tai-thiet");
      text(s, t, { x: M + i * 3.05, y: 2.15, w: 2.85, h: 0.9, fontSize: 19, bold: true, align: "center", valign: "middle" });
    });
    [["HV", "$R = ⋃_{i} (R_{i1} ⋈ R_{i2})$"], ["VH", "$R = (R_{11} ∪ … ∪ R_{1n}) ⋈ R_{2}$"]].forEach(([k, f], i) => {
      const y = 3.35 + i * 1.5;
      card(s, M, y, 5.95, 1.25, C.background2, "cong-thuc");
      text(s, k, { x: M + 0.3, y, w: 0.9, h: 1.25, fontSize: 22, bold: true, color: i ? C.accent2 : C.accent1, valign: "middle", fontFace: THEME.headFontFace });
      text(s, f, { x: M + 1.25, y, w: 4.6, h: 1.25, fontSize: 24, valign: "middle" });
    });
    const boxes = [["FaCircleCheck", C.accent4, "Đúng đắn", "Mỗi bước ngang và dọc thỏa **đầy đủ – tái thiết – rời nhau** $⇒$ cả cây thỏa"],
      ["FaTriangleExclamation", C.accent1, "Lưu ý ở VH", "Chỉ chia ngang được mảnh dọc **có chứa thuộc tính của vị từ** (ví dụ MaCN). NV_NS không có MaCN nên không chia theo chi nhánh được."]];
    for (const [i, [ic, col, h, d]] of boxes.entries()) {
      const y = 1.75 + i * 2.35;
      card(s, 7.05, y, 5.7, 1.95, C.background2, "the-ghi-chu");
      await iconDot(s, ic, 7.35, y + 0.3, 0.6, col);
      text(s, paras([{ t: h, bold: true, size: 19, space: 6 }, { t: d, size: 16 }]), { x: 8.15, y: y + 0.3, w: 4.35, h: 1.8 });
    }
  }

  // ================================================================ 10. Bài toán
  {
    const s = content("Ứng dụng", "4 · ỨNG DỤNG CHO QUẢN LÝ ĐƠN HÀNG", "Bài toán quản lý đơn hàng");
    text(s, "Công ty thương mại X: **3 chi nhánh** và **trụ sở chính** · mỗi khách hàng do **một** chi nhánh quản lý",
      { x: M, y: 1.7, w: CW, h: 0.45, fontSize: 18 });
    card(s, M, 2.45, 5.6, 2.95, C.background2, "chi-nhanh");
    text(s, "Chi nhánh", { x: M + 0.35, y: 2.65, w: 4, h: 0.45, fontSize: 20, bold: true });
    [["Hà Nội", C.accent3], ["Đà Nẵng", C.accent4], ["TP.HCM", C.accent5]].forEach(([t, col], i) => {
      card(s, M + 0.35 + i * 1.65, 3.25, 1.5, 0.5, col, "nhan-chi-nhanh");
      text(s, t, { x: M + 0.35 + i * 1.65, y: 3.25, w: 1.5, h: 0.5, fontSize: 15, bold: true, color: C.background1, align: "center", valign: "middle" });
    });
    text(s, paras([{ t: "Tra cứu khách, lập và xử lý đơn hàng của khách mình", space: 4 },
      { t: "Tần suất **rất cao**", color: C.text2 }], { fontSize: 16 }), { x: M + 0.35, y: 4.0, w: 5.0, h: 1.2 });
    card(s, 6.55, 2.45, 6.18, 2.95, C.background2, "tru-so");
    text(s, "Trụ sở chính (S0)", { x: 6.9, y: 2.65, w: 5, h: 0.45, fontSize: 20, bold: true });
    const depts = [["FaCalculator", "Kế toán", "hạn mức, công nợ khách ở cả 3 miền"],
      ["FaLock", "Nhân sự", "lương, CCCD, tài khoản ngân hàng (nhạy cảm)"],
      ["FaChartLine", "Ban giám đốc", "báo cáo doanh thu toàn công ty"]];
    for (const [i, [ic, h, d]] of depts.entries()) {
      const y = 3.25 + i * 0.68;
      await iconDot(s, ic, 6.9, y, 0.5, C.accent6);
      text(s, `**${h}:** ${d}`, { x: 7.55, y, w: 5.0, h: 0.5, fontSize: 16, valign: "middle" });
    }
    card(s, M, 5.7, CW, 0.9, C.text1, "ket-luan-bai-toan");
    text(s, "Mỗi nơi cần một phần dữ liệu khác nhau, **cả theo dòng lẫn theo cột** → phù hợp với phân mảnh hỗn hợp",
      { x: M + 0.35, y: 5.7, w: CW - 0.7, h: 0.9, fontSize: 18, color: C.background1, valign: "middle" });
  }

  // ================================================================ 11. Lược đồ & truy vấn
  {
    const s = content("Ứng dụng", "4 · ỨNG DỤNG CHO QUẢN LÝ ĐƠN HÀNG", "Lược đồ toàn cục và phân tích truy vấn");
    image(s, "luoc_do_quan_he.png", M, 1.7, 5.9, 2210 / 1210, "Lược đồ quan hệ toàn cục 6 bảng");
    text(s, "6 quan hệ: ChiNhanh, KhachHang, NhanVien, SanPham, DonHang, ChiTietDonHang",
      { x: M, y: 5.05, w: 5.9, h: 0.6, fontSize: 15, color: C.text2 });
    const hd = (t) => ({ text: t, options: { bold: true, color: HEX.lt1, fill: { color: HEX.dk1 } } });
    const freq = { "Rất cao": TINT.red, "Trung bình": TINT.amber, "Thấp": TINT.gray };
    const q = [["Q1–Q2", "Tra cứu khách, lập/xử lý đơn", "Chi nhánh", "Rất cao"], ["Q3", "Hạn mức, công nợ theo miền", "Trụ sở", "Trung bình"],
      ["Q4", "Danh sách nhân viên chi nhánh", "Chi nhánh", "Trung bình"], ["Q5", "Tính lương", "Trụ sở", "Thấp"],
      ["Q6", "Báo cáo doanh thu", "Trụ sở", "Thấp"]];
    s.addTable([[hd(""), hd("Ứng dụng"), hd("Tại"), hd("Tần suất")],
      ...q.map((r, i) => r.map((t, j) => ({ text: t, options: { bold: j === 0, fill: { color: j === 3 ? freq[t] : i % 2 ? "FFFFFF" : HEX.lt2 } } })))],
    { x: 6.85, y: 1.7, w: 5.88, colW: [0.8, 2.75, 1.1, 1.23], rowH: 0.4, fontSize: 14, color: HEX.dk1, margin: 0.06,
      border: { type: "solid", pt: 1, color: "FFFFFF" }, valign: "middle" });
    image(s, "ma_tran_su_dung_KhachHang.png", 6.85, 4.35, 5.88, 1745 / 563, "Ma trận sử dụng thuộc tính của KhachHang");
    text(s, "Ma trận sử dụng KhachHang → 2 nhóm cột: **giao dịch** và **tài chính**",
      { x: 6.85, y: 6.3, w: 5.88, h: 0.4, fontSize: 15 });
  }

  // ================================================================ 12. KhachHang HV
  {
    const s = content("Ứng dụng", "4 · ỨNG DỤNG CHO QUẢN LÝ ĐƠN HÀNG", "Thiết kế KhachHang: chiến lược HV");
    text(s, paras([
      { t: "**Bước 1 – ngang**", space: 2, color: C.accent1 },
      { t: "$KHᵢ = σ_{MaCN='CN0i'}(KhachHang)$, i = 1..3", space: 12 },
      { t: "**Bước 2 – dọc trên từng KHᵢ**", space: 2, color: C.accent2 },
      { t: "$KHᵢ_GD = π_{MaKH, HoTen, SDT, Email, DiaChi, MaCN}(KHᵢ)$ → đặt tại **chi nhánh i**", bullet: true, size: 15 },
      { t: "$KHᵢ_TC = π_{MaKH, HanMucNo, CongNo, DiemTichLuy}(KHᵢ)$ → đặt tại **trụ sở**", bullet: true, size: 15, space: 12 },
      { t: "**Tái thiết:** $KhachHang = ⋃_{i} (KHᵢ_GD ⋈_{MaKH} KHᵢ_TC)$" },
    ], { fontSize: 17 }), { x: M, y: 1.75, w: 5.7, h: 4.2 });
    image(s, "cay_HV_KhachHang.png", 6.55, 1.7, 6.2, 2055 / 1025, "Cây phân mảnh HV của KhachHang, 6 lá");
    card(s, 6.55, 5.0, 6.2, 1.55, TINT.amber, "vi-sao");
    text(s, paras([{ t: "Vì sao chọn HV?", bold: true, size: 18, space: 4 },
      { t: "Kế toán cần **báo cáo công nợ theo từng miền**, nên phần TC vẫn được tách theo miền", size: 16 }]),
    { x: 6.85, y: 5.15, w: 5.6, h: 1.3 });
  }

  // ================================================================ 13. NhanVien VH + DonHang
  {
    const s = content("Ứng dụng", "4 · ỨNG DỤNG CHO QUẢN LÝ ĐƠN HÀNG", "Thiết kế NhanVien (VH) và DonHang");
    text(s, "NhanVien · chiến lược VH", { x: M, y: 1.7, w: 5.9, h: 0.4, fontSize: 18, bold: true, color: C.accent2 });
    image(s, "cay_VH_NhanVien.png", M, 2.15, 5.9, 1900 / 1025, "Cây phân mảnh VH của NhanVien");
    text(s, paras([
      { t: "NV_NS (lương, CCCD, tài khoản) chỉ đặt tại **trụ sở**", bullet: true, space: 4 },
      { t: "$NhanVien = (NV_CV₁ ∪ NV_CV₂ ∪ NV_CV₃) ⋈_{MaNV} NV_NS$", bullet: true },
    ], { fontSize: 15 }), { x: M, y: 5.45, w: 5.9, h: 1.2 });
    const rx = 6.85, rw = 5.88;
    text(s, "DonHang, ChiTietDonHang · ngang dẫn xuất", { x: rx, y: 1.7, w: rw, h: 0.4, fontSize: 18, bold: true, color: C.accent1 });
    text(s, paras([{ t: "$DHᵢ = DonHang ⋉ KHᵢ$", space: 4 }, { t: "$CTDHᵢ = ChiTietDonHang ⋉ DHᵢ$" }], { fontSize: 20 }),
      { x: rx, y: 2.25, w: rw, h: 0.95 });
    image(s, "phan_manh_dan_xuat.png", rx, 3.3, rw, 1590 / 348, "Chuỗi phân mảnh dẫn xuất KH → DH → CTDH");
    text(s, "Kết nối khách – đơn – chi tiết luôn chạy **tại chỗ** ở chi nhánh", { x: rx, y: 4.65, w: rw, h: 0.4, fontSize: 15, color: C.text2 });
    card(s, rx, 5.3, rw, 1.25, C.background2, "nhan-ban");
    await iconDot(s, "FaRotate", rx + 0.3, 5.6, 0.62, C.accent6);
    text(s, paras([{ t: "ChiNhanh, SanPham", bold: true, size: 17, space: 2 }, { t: "Nhỏ, chủ yếu đọc → **nhân bản** ở cả 4 site", size: 16 }]),
      { x: rx + 1.15, y: 5.45, w: rw - 1.35, h: 1.0 });
  }

  // ================================================================ 14. Cấp phát
  {
    const s = content("Ứng dụng", "4 · ỨNG DỤNG CHO QUẢN LÝ ĐƠN HÀNG", "Lược đồ cấp phát");
    image(s, "cap_phat_4_site.png", M, 1.65, 7.6, 1900 / 1179, "Lược đồ cấp phát các mảnh cho 4 site");
    const rx = 8.6, rw = W - M - rx;
    text(s, "5/6", { x: rx, y: 1.7, w: rw, h: 1.1, fontSize: 64, bold: true, color: C.accent1, fontFace: THEME.headFontFace });
    text(s, "nhóm truy vấn chạy hoàn toàn cục bộ", { x: rx, y: 2.8, w: rw, h: 0.4, fontSize: 15, color: C.text2 });
    const qs = [[C.accent4, "Q1, Q2, Q4", "tần suất cao → cục bộ tại **chi nhánh**"],
      [C.accent4, "Q3, Q5", "cục bộ tại **trụ sở**"],
      [C.accent1, "Q6", "báo cáo toàn công ty → cần dữ liệu **nhiều site**"]];
    for (const [i, [col, h, d]] of qs.entries()) {
      const y = 3.45 + i * 1.1;
      card(s, rx, y, rw, 0.98, C.background2, "truy-van");
      await iconDot(s, i < 2 ? "FaCircleCheck" : "FaLink", rx + 0.18, y + 0.22, 0.54, col);
      text(s, paras([{ t: h, bold: true, size: 16, space: 0 }, { t: d, size: 14 }]), { x: rx + 0.88, y: y + 0.06, w: rw - 1.0, h: 0.86, valign: "middle" });
    }
  }

  // ================================================================ 15. Demo
  {
    const s = content("Ứng dụng", "4 · ỨNG DỤNG CHO QUẢN LÝ ĐƠN HÀNG", "Demo trên SQL Server");
    const rows = [["FaDatabase", "Mỗi site là **một database**: QLDH_TRUSO, QLDH_HN, QLDH_DN, QLDH_HCM"],
      ["FaLink", "Trụ sở dùng **synonym** + **view tái thiết** → trong suốt phân mảnh và vị trí"],
      ["FaCircleCheck", "Kiểm tra tự động **3 quy tắc đúng đắn**: 14/14 **ĐẠT**"],
      ["FaShieldHalved", "Vị từ ràng buộc bằng **CHECK**; chi nhánh **không có cột lương**"],
      ["FaRotate", "Giao dịch phân tán: lập đơn + cập nhật công nợ **cùng thành công hoặc cùng hủy**"]];
    for (const [i, [ic, t]] of rows.entries()) {
      const y = 1.75 + i * 0.97;
      await iconDot(s, ic, M, y, 0.56, i === 2 ? C.accent4 : C.text1);
      text(s, t, { x: M + 0.8, y: y - 0.08, w: 5.1, h: 0.75, fontSize: 16, valign: "middle" });
    }
    const shots = ["slide15_1_object_explorer", "slide15_2_kiem_tra", "slide15_3_toan_cuc", "slide15_4_giao_dich"];  // cắt từ ảnh demo_01, 05, 07, 08
    const sw = 2.95, sh = 2.3, gx = 6.85;
    shots.forEach((f, i) => {
      const x = gx + (i % 2) * (sw + 0.18), y = 1.75 + Math.floor(i / 2) * (sh + 0.2);
      const file = path.join(ROOT, "assets", "screenshots", `${f}.png`);
      if (fs.existsSync(file)) {
        // ảnh chụp SSMS thật: co vừa khung, giữ tỉ lệ, căn giữa
        const b = fs.readFileSync(file), iw = b.readUInt32BE(16), ih = b.readUInt32BE(20);
        const k = Math.min((sw - 0.1) / iw, (sh - 0.1) / ih), w = iw * k, h = ih * k;
        s.addShape(pres.shapes.RECTANGLE, { x, y, w: sw, h: sh, fill: { color: C.background2 },
          line: { color: HEX.dk2, width: 0.75 }, objectName: "khung-anh-demo" });
        s.addImage({ path: file, x: x + (sw - w) / 2, y: y + (sh - h) / 2, w, h, objectName: f });
      } else {
        s.addShape(pres.shapes.ROUNDED_RECTANGLE, { x, y, w: sw, h: sh, rectRadius: 0.1, fill: { color: C.background2 },
          line: { color: HEX.dk2, width: 1.25, dashType: "dash" }, objectName: "khung-anh-demo" });
        text(s, `Chèn ảnh: ${f}.png`, { x: x + 0.15, y, w: sw - 0.3, h: sh, fontSize: 12, color: C.text2, align: "center", valign: "middle" });
      }
    });
  }

  // ================================================================ 16. Đánh giá & kết luận
  {
    const s = content("Kết luận", "5 · ĐÁNH GIÁ VÀ KẾT LUẬN", "Đánh giá và kết luận");
    const cw = (CW - 0.3) / 2;
    [[M, "Ưu điểm", C.accent4, TINT.green, "FaCircleCheck",
      ["Đa số truy vấn chạy cục bộ", "Bảo mật dữ liệu nhân sự", "Báo cáo theo miền nhanh"]],
    [M + cw + 0.3, "Đánh đổi", C.accent1, TINT.amber, "FaTriangleExclamation",
      ["Lập đơn phải cập nhật công nợ ở trụ sở → **giao dịch phân tán** (cần 2PC khi nhiều máy)",
        "Phải thiết kế lại khi đổi cơ cấu chi nhánh"]],
    ].forEach(([x, h, col, tint, ic, items]) => {
      card(s, x, 1.7, cw, 2.95, tint, "danh-gia");
      text(s, h, { x: x + 0.35, y: 1.9, w: cw - 0.7, h: 0.45, fontSize: 21, bold: true, color: col });
      text(s, paras(items.map((t) => ({ t, bullet: true, space: 6 })), { fontSize: 17 }), { x: x + 0.35, y: 2.5, w: cw - 0.7, h: 2.0 });
    });
    card(s, M, 4.95, CW, 1.05, C.text1, "ket-luan");
    text(s, "**Kết luận:** phân mảnh hỗn hợp phù hợp khi nhu cầu truy cập khác nhau **cả theo dòng lẫn theo cột**",
      { x: M + 0.4, y: 4.95, w: CW - 0.8, h: 1.05, fontSize: 19, color: C.background1, valign: "middle" });
    text(s, "**Hướng phát triển:** chạy trên nhiều máy bằng Linked Server · đồng bộ bản nhân bản · tối ưu truy vấn phân tán",
      { x: M, y: 6.2, w: CW, h: 0.45, fontSize: 16, color: C.text2 });
  }

  // ================================================================ 17. Cảm ơn
  {
    const s = dark("Kết luận");
    text(s, "CẢM ƠN THẦY VÀ CÁC BẠN ĐÃ LẮNG NGHE", { x: M + 0.1, y: 2.2, w: 7.7, h: 1.9, fontSize: 38, bold: true,
      fontFace: THEME.headFontFace, color: C.background1, valign: "middle" });
    text(s, "Hỏi & Đáp", { x: M + 0.1, y: 4.3, w: 6, h: 0.7, fontSize: 28, bold: true, color: C.accent1 });
    text(s, "Trần Gia Thịnh · Phạm Minh Triết", { x: M + 0.1, y: 5.3, w: 6, h: 0.4, fontSize: 16, color: "D1D5DB" });
    grid(s, 9.25, 1.9);
  }

  await pres.writeFile({ fileName: OUT });
  await applyTheme(OUT, THEME);
  console.log("Đã ghi", OUT, "·", n, "slide");
}
main().catch((e) => { console.error(e); process.exit(1); });
