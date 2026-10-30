// Dựng báo cáo Word từ các file Markdown trong docs/draft/.
//   cd docs/build && node build_docx.js       → docs/BaoCao_PhanManhHonHop.docx
//   powershell -File finalize_word.ps1        → cập nhật mục lục, xuất PDF (cần MS Word)
//
// Cú pháp Markdown được hỗ trợ (tập con):
//   # / ## / ###            heading cấp 1–3 ("# CHƯƠNG n." tăng số chương để đánh số hình/bảng)
//   Bảng: <tên>             đặt ngay trước bảng | a | b | → "Bảng n.k: <tên>"
//   ![<tên>](<đường dẫn>)   hình (đường dẫn tính từ thư mục gốc đồ án) → "Hình n.k: <tên>"
//   $$ <công thức>          dòng công thức canh giữa, font Cambria Math
//   - / "  - "              gạch đầu dòng cấp 1 / 2;   "1. " danh sách đánh số
//   ```sql ... ```          khối mã
//   [[ẢNH: ...]]            chỗ chèn ảnh chụp (tô vàng để dễ tìm)
//   <<<DOTLINES n>>>, <<<REFS>>>…<<<END>>>, <<<CODEFILE path>>>   các khối đặc biệt
//   **đậm**, *nghiêng*, `mã` trong dòng
const fs = require("fs");
const path = require("path");
const {
  Document, Packer, Paragraph, TextRun, ImageRun, Table, TableRow, TableCell, WidthType, BorderStyle,
  AlignmentType, HeadingLevel, LevelFormat, ShadingType, TableOfContents, StyleLevel, Header, Footer,
  PageNumber, NumberFormat, PositionalTab, PositionalTabAlignment, PositionalTabRelativeTo,
  PositionalTabLeader, TabStopType, VerticalAlign, PageBorderDisplay, PageBorderOffsetFrom,
} = require("docx");

const ROOT = path.resolve(__dirname, "..", "..");
const DRAFT = path.join(ROOT, "docs", "draft");
// node build_docx.js --short → bản rút gọn (< 30 trang): nội dung lấy từ docs/draft_short/,
// file nào không có ở đó (phần đầu, tài liệu tham khảo) thì dùng chung với bản đầy đủ
const SHORT = process.argv.includes("--short");
const DRAFT_SHORT = path.join(ROOT, "docs", "draft_short");
const OUT = path.join(ROOT, "docs", SHORT ? "BaoCao_PhanManhHonHop_RutGon.docx" : "BaoCao_PhanManhHonHop.docx");
const draftFile = (f) => (SHORT && fs.existsSync(path.join(DRAFT_SHORT, f)) ? path.join(DRAFT_SHORT, f) : path.join(DRAFT, f));

const FONT = "Times New Roman";
const MATH_FONT = "Cambria Math";
const MATH_CHARS = /([⇒∇∈∧∨∪⊆⋃⋈⋉]+)/; // các ký hiệu Times New Roman không có
const TEXT_WIDTH = 9070; // A4 21cm − lề trái 3cm − lề phải 2cm = 16cm ≈ 9070 DXA
const BODY = 26; // cỡ chữ 13pt (đơn vị nửa point)
const LINE = 312; // giãn dòng 1.3 (240 = đơn)

const COVER = {
  gvhd: "ThS. Nguyễn Văn Danh",
  sv: [["Trần Gia Thịnh", "2380602136"], ["Phạm Minh Triết", "2380605829"]],
  lop: "23DTHE3",
  title: "TÌM HIỂU PHÂN MẢNH HỖN HỢP TRONG CSDL PHÂN TÁN VÀ ỨNG DỤNG CHO QUẢN LÝ ĐƠN HÀNG",
  ngay: "TP. Hồ Chí Minh, tháng 10 năm 2026",
};

// ------------------------------------------------------------------ inline
function fontSplit(text, base) {
  return text.split(MATH_CHARS).filter((s) => s.length).map((s) =>
    new TextRun({ ...base, text: s, ...(MATH_CHARS.test(s) ? { font: MATH_FONT } : {}) }));
}

// Chỉ số dưới sau toán tử: σ_F, π_{A, B}, ⋈_MaKH, Σ_{k: …}, ⋃_{i=1..3}
// (chỉ sau các ký hiệu này, vì "_" còn nằm trong tên mảnh như KH_1_GD)
const SUB = /([σπ⋈⋉Σ⋃])_(\{[^}]*\}|[^\s(]+)/g;
function mathSplit(text, base) {
  const runs = [];
  let last = 0, m;
  SUB.lastIndex = 0;
  while ((m = SUB.exec(text))) {
    runs.push(...fontSplit(text.slice(last, m.index) + m[1], base));
    const sub = m[2].startsWith("{") ? m[2].slice(1, -1) : m[2];
    runs.push(...fontSplit(sub, { ...base, subScript: true }));
    last = m.index + m[0].length;
  }
  runs.push(...fontSplit(text.slice(last), base));
  return runs;
}

function inline(text, base = {}) {
  const runs = [];
  // *nghiêng* chỉ khi dấu * mở không dính sau chữ (tránh "ChiNhanh*, SanPham*")
  const re = /(\*\*[^*]+\*\*|(?<![\p{L}\p{N}])\*\p{L}[^*]*\*|`[^`]+`)/gu;
  let last = 0, m;
  while ((m = re.exec(text))) {
    if (m.index > last) runs.push(...mathSplit(text.slice(last, m.index), base));
    const tok = m[0];
    if (tok.startsWith("**")) runs.push(...mathSplit(tok.slice(2, -2), { ...base, bold: true }));
    else if (tok.startsWith("`")) runs.push(new TextRun({ ...base, text: tok.slice(1, -1), font: "Consolas", size: 22 }));
    else runs.push(...mathSplit(tok.slice(1, -1), { ...base, italics: true }));
    last = m.index + tok.length;
  }
  if (last < text.length) runs.push(...mathSplit(text.slice(last), base));
  return runs;
}

// ------------------------------------------------------------------ block helpers
const para = (text, opts = {}) => new Paragraph({
  alignment: AlignmentType.JUSTIFIED,
  indent: { firstLine: 567 },
  spacing: { line: LINE, after: 120 },
  ...opts,
  children: typeof text === "string" ? inline(text, opts.run || {}) : text,
});

const centered = (text, run = {}, spacing = { after: 120 }) => new Paragraph({
  alignment: AlignmentType.CENTER, spacing, children: inline(text, run),
});

function pngSize(file) {
  const b = fs.readFileSync(file);
  return { w: b.readUInt32BE(16), h: b.readUInt32BE(20) };
}

function image(rel) {
  const file = path.join(ROOT, rel);
  const { w, h } = pngSize(file);
  const maxW = 590, maxH = SHORT ? 300 : 620; // pixel ở 96 dpi, vừa khung chữ 16cm; bản rút gọn hạ chiều cao hình
  const s = Math.min(maxW / w, maxH / h);
  return new Paragraph({
    alignment: AlignmentType.CENTER, keepNext: true, spacing: { before: 120, after: 60 },
    children: [new ImageRun({ type: "png", data: fs.readFileSync(file), transformation: { width: Math.round(w * s), height: Math.round(h * s) } })],
  });
}

const caption = (label, text, style) => new Paragraph({
  style, alignment: AlignmentType.CENTER, keepNext: style === "CaptionBang",
  spacing: { before: style === "CaptionBang" ? 120 : 0, after: 160 },
  children: [new TextRun({ text: label + ": ", bold: true, italics: true }), ...inline(text, { italics: true })],
});

function codeLines(lines) {
  return lines.map((l, i) => new Paragraph({
    spacing: { line: 240, before: i === 0 ? 80 : 0, after: i === lines.length - 1 ? 160 : 0 },
    shading: { type: ShadingType.CLEAR, fill: "F3F4F6", color: "auto" },
    indent: { left: 113, right: 113 },
    children: [new TextRun({ text: l.replace(/\t/g, "    ") || " ", font: "Consolas", size: 17 })],
  }));
}

function table(rows) {
  const cells = rows.map((r) => r.replace(/^\||\|$/g, "").split("|").map((c) => c.trim()));
  const header = cells[0];
  const body = cells.slice(2); // bỏ dòng |---|
  const n = header.length;
  // độ rộng cột theo độ dài nội dung, có chặn trên/dưới
  const len = header.map((_, j) => Math.max(...[header, ...body].map((r) => Math.min((r[j] || "").length, 60))) + 4);
  const total = len.reduce((a, b) => a + b, 0);
  let widths = len.map((l) => Math.max(700, Math.round((l / total) * TEXT_WIDTH)));
  const scale = TEXT_WIDTH / widths.reduce((a, b) => a + b, 0);
  widths = widths.map((w) => Math.floor(w * scale));
  widths[n - 1] += TEXT_WIDTH - widths.reduce((a, b) => a + b, 0);
  const size = n >= 5 ? 21 : 23;
  const border = { style: BorderStyle.SINGLE, size: 4, color: "808080" };
  const mkRow = (r, isHead) => new TableRow({
    tableHeader: isHead, cantSplit: true,
    children: r.map((c, j) => new TableCell({
      width: { size: widths[j], type: WidthType.DXA },
      verticalAlign: VerticalAlign.CENTER,
      margins: { top: 50, bottom: 50, left: 90, right: 90 },
      shading: isHead ? { type: ShadingType.CLEAR, fill: "D9E2F3", color: "auto" } : undefined,
      borders: { top: border, bottom: border, left: border, right: border },
      children: [new Paragraph({
        alignment: isHead ? AlignmentType.CENTER : AlignmentType.LEFT, spacing: { line: 252 },
        children: inline(c, { size, bold: isHead || undefined }),
      })],
    })),
  });
  return new Table({
    width: { size: TEXT_WIDTH, type: WidthType.DXA }, columnWidths: widths,
    rows: [mkRow(header, true), ...body.map((r) => mkRow(r, false))],
  });
}

// ------------------------------------------------------------------ markdown → blocks
function render(files, { front = false } = {}) {
  const out = [];
  let chapter = 0, nFig = 0, nTab = 0, listId = 0;
  let pendingCaption = null;
  for (const f of files) {
    const lines = fs.readFileSync(draftFile(f), "utf8").replace(/^﻿/, "").split(/\r?\n/);
    for (let i = 0; i < lines.length; i++) {
      const line = lines[i];
      const t = line.trim();
      if (!t) continue;

      if (t.startsWith("```")) {
        const buf = [];
        for (i++; i < lines.length && !lines[i].trim().startsWith("```"); i++) buf.push(lines[i]);
        out.push(...codeLines(buf));
        continue;
      }
      let m;
      if ((m = t.match(/^<<<CODEFILE (.+)>>>$/))) {
        const src = fs.readFileSync(path.join(ROOT, m[1]), "utf8").replace(/^﻿/, "").replace(/\s+$/, "");
        out.push(...codeLines(src.split(/\r?\n/)));
        continue;
      }
      if ((m = t.match(/^<<<DOTLINES (\d+)>>>$/))) {
        for (let k = 0; k < +m[1]; k++) out.push(new Paragraph({ spacing: { line: 360 }, children: [new TextRun({ children: [new PositionalTab({ alignment: PositionalTabAlignment.RIGHT, relativeTo: PositionalTabRelativeTo.MARGIN, leader: PositionalTabLeader.DOT })] })] }));
        continue;
      }
      if (t === "<<<REFS>>>") {
        for (i++; i < lines.length && lines[i].trim() !== "<<<END>>>"; i++) {
          if (!lines[i].trim()) continue;
          out.push(new Paragraph({ alignment: AlignmentType.LEFT, spacing: { line: LINE, after: 120 }, indent: { left: 567, hanging: 567 }, children: inline(lines[i].trim()) }));
        }
        continue;
      }
      if ((m = t.match(/^(#{1,3}) (.+)$/))) {
        const level = m[1].length, text = m[2];
        if (level === 1) {
          const cm = text.match(/^CHƯƠNG (\d+)/);
          if (cm) { chapter = +cm[1]; nFig = 0; nTab = 0; }
          out.push(new Paragraph(front
            ? { style: "TitleFront", pageBreakBefore: true, children: inline(text) }
            : { heading: HeadingLevel.HEADING_1, pageBreakBefore: true, children: inline(text) }));
        } else {
          out.push(new Paragraph({ heading: level === 2 ? HeadingLevel.HEADING_2 : HeadingLevel.HEADING_3, children: inline(text) }));
        }
        continue;
      }
      if ((m = t.match(/^Bảng: (.+)$/))) { pendingCaption = m[1]; continue; }
      if (t.startsWith("|")) {
        const rows = [];
        for (; i < lines.length && lines[i].trim().startsWith("|"); i++) rows.push(lines[i].trim());
        i--;
        if (pendingCaption) {
          out.push(front || !chapter
            ? centered(pendingCaption, { bold: true }, { before: 120, after: 160 })
            : caption(`Bảng ${chapter}.${++nTab}`, pendingCaption, "CaptionBang"));
          pendingCaption = null;
        }
        out.push(table(rows));
        out.push(new Paragraph({ spacing: { after: 60 }, children: [] }));
        continue;
      }
      if ((m = t.match(/^!\[(.+)\]\((.+)\)$/))) {
        out.push(image(m[2]));
        out.push(caption(`Hình ${chapter}.${++nFig}`, m[1], "CaptionHinh"));
        continue;
      }
      if (t.startsWith("$$")) {
        out.push(new Paragraph({ alignment: AlignmentType.CENTER, spacing: { before: 80, after: 160, line: LINE },
          children: mathSplit(t.slice(2).trim(), { font: MATH_FONT, size: 24 }) }));
        continue;
      }
      if ((m = t.match(/^\[\[(.+)\]\]$/))) {
        out.push(new Paragraph({ alignment: AlignmentType.CENTER, spacing: { before: 120, after: 160 },
          children: [new TextRun({ text: `[${m[1]}]`, italics: true, highlight: "yellow" })] }));
        continue;
      }
      if ((m = line.match(/^(\s*)- (.+)$/))) {
        out.push(new Paragraph({ numbering: { reference: "bullets", level: m[1].length >= 2 ? 1 : 0 }, alignment: AlignmentType.JUSTIFIED, spacing: { line: LINE, after: 60 }, children: inline(m[2]) }));
        continue;
      }
      if ((m = t.match(/^(\d+)\. (.+)$/))) {
        if (m[1] === "1") listId++;
        out.push(new Paragraph({ numbering: { reference: "numbers", level: 0, instance: listId }, alignment: AlignmentType.JUSTIFIED, spacing: { line: LINE, after: 60 }, children: inline(m[2]) }));
        continue;
      }
      // đoạn chữ thường; dòng ngắn không dấu chấm cuối trong phần đầu (chữ ký, ngày tháng) thì canh phải
      if (front && t.length < 60 && !/[.:;]$/.test(t)) {
        out.push(new Paragraph({ alignment: AlignmentType.RIGHT, spacing: { line: LINE, after: 60 }, children: inline(t, { italics: true }) }));
        continue;
      }
      out.push(para(t));
    }
  }
  return out;
}

// ------------------------------------------------------------------ bìa
function cover() {
  const c = (text, size, bold = true, after = 80, color) => new Paragraph({
    alignment: AlignmentType.CENTER, spacing: { after },
    children: [new TextRun({ text, size, bold, color })],
  });
  const info = (label, value, after = 100) => new Paragraph({
    indent: { left: 1134 }, spacing: { after },
    tabStops: [{ type: TabStopType.LEFT, position: 3900 }, { type: TabStopType.LEFT, position: 6200 }],
    children: [new TextRun({ text: label, bold: true }), new TextRun({ text: "\t" + value })],
  });
  return [
    c("BỘ GIÁO DỤC VÀ ĐÀO TẠO", 26),
    c("TRƯỜNG ĐẠI HỌC CÔNG NGHỆ TP. HỒ CHÍ MINH", 26),
    c("KHOA CÔNG NGHỆ THÔNG TIN", 26, true, 900),
    (() => { // logo HUTECH rộng khoảng 7,5 cm
      const logo = path.join(ROOT, "assets", "logo_hutech.png"), { w, h } = pngSize(logo), lw = 285;
      return new Paragraph({ alignment: AlignmentType.CENTER, spacing: { after: 700 },
        children: [new ImageRun({ type: "png", data: fs.readFileSync(logo), transformation: { width: lw, height: Math.round(lw * h / w) } })] });
    })(),
    c(SHORT ? "ĐỒ ÁN MÔN HỌC – BẢN RÚT GỌN" : "ĐỒ ÁN MÔN HỌC", 32, true, 60),
    c("CƠ SỞ DỮ LIỆU NÂNG CAO", 36, true, 1000),
    new Paragraph({ alignment: AlignmentType.CENTER, spacing: { after: 1400, line: 360 },
      children: [new TextRun({ text: COVER.title, size: 34, bold: true, color: "1F3864" })] }),
    info("Ngành:", "CÔNG NGHỆ THÔNG TIN"),
    info("Giảng viên hướng dẫn:", COVER.gvhd),
    info("Sinh viên thực hiện:", `${COVER.sv[0][0]}\tMSSV: ${COVER.sv[0][1]}`, 40),
    info("", `${COVER.sv[1][0]}\tMSSV: ${COVER.sv[1][1]}`),
    info("Lớp:", COVER.lop, 2400),
    c(COVER.ngay, 26, true, 0),
  ];
}

// ------------------------------------------------------------------ tài liệu
const frontTitle = (text) => new Paragraph({ style: "TitleFront", pageBreakBefore: true, children: [new TextRun(text)] });

// bản rút gọn: mục lục chỉ 2 cấp, danh mục bảng chung trang với danh mục hình, không có phụ lục
const sameTitle = (text) => new Paragraph({ style: "TitleFront", spacing: { before: 480, after: 360 }, children: [new TextRun(text)] });
const frontBlocks = [
  ...render(["00a_phan_dau.md"], { front: true }),
  frontTitle("MỤC LỤC"),
  new TableOfContents("Mục lục", { hyperlink: true, headingStyleRange: SHORT ? "1-2" : "1-3" }),
  ...render(["00b_viet_tat.md"], { front: true }),
  frontTitle("DANH MỤC HÌNH"),
  new TableOfContents("Danh mục hình", { hyperlink: true, stylesWithLevels: [new StyleLevel("CaptionHinh", 1)] }),
  (SHORT ? sameTitle : frontTitle)("DANH MỤC BẢNG"),
  new TableOfContents("Danh mục bảng", { hyperlink: true, stylesWithLevels: [new StyleLevel("CaptionBang", 1)] }),
];

const mainBlocks = render(["01_mo_dau.md", "ch1.md", "ch2.md", "ch3.md", "ch4.md", "ch5.md", "09_tltk.md",
  ...(SHORT ? [] : ["10_phu_luc.md"])]);

const margins = { top: 1134, bottom: 1134, left: 1701, right: 1134, header: 567, footer: 567 };
const pageFooter = new Footer({ children: [new Paragraph({ alignment: AlignmentType.CENTER, children: [new TextRun({ children: [PageNumber.CURRENT], size: 24 })] })] });
const dbl = { style: BorderStyle.DOUBLE, size: 12, color: "1F3864", space: 24 };

const doc = new Document({
  creator: "Trần Gia Thịnh, Phạm Minh Triết",
  title: "Tìm hiểu phân mảnh hỗn hợp trong CSDL phân tán và ứng dụng cho quản lý đơn hàng",
  styles: {
    default: { document: { run: { font: FONT, size: BODY }, paragraph: { spacing: { line: LINE } } } },
    paragraphStyles: [
      { id: "Heading1", name: "Heading 1", basedOn: "Normal", next: "Normal", quickFormat: true,
        run: { font: FONT, size: 28, bold: true, color: "000000" },
        paragraph: { alignment: AlignmentType.CENTER, spacing: { before: 0, after: 360 }, outlineLevel: 0, keepNext: true } },
      { id: "Heading2", name: "Heading 2", basedOn: "Normal", next: "Normal", quickFormat: true,
        run: { font: FONT, size: 26, bold: true, color: "000000" },
        paragraph: { spacing: { before: 240, after: 120 }, outlineLevel: 1, keepNext: true } },
      { id: "Heading3", name: "Heading 3", basedOn: "Normal", next: "Normal", quickFormat: true,
        run: { font: FONT, size: 26, bold: true, italics: true, color: "000000" },
        paragraph: { spacing: { before: 180, after: 100 }, outlineLevel: 2, keepNext: true } },
      { id: "TitleFront", name: "TitleFront", basedOn: "Normal", next: "Normal",
        run: { font: FONT, size: 28, bold: true },
        paragraph: { alignment: AlignmentType.CENTER, spacing: { after: 360 } } },
      { id: "CaptionHinh", name: "CaptionHinh", basedOn: "Normal", next: "Normal", run: { font: FONT, size: 24 } },
      { id: "CaptionBang", name: "CaptionBang", basedOn: "Normal", next: "Normal", run: { font: FONT, size: 24 } },
    ],
  },
  numbering: {
    config: [
      { reference: "bullets", levels: [
        { level: 0, format: LevelFormat.BULLET, text: "–", alignment: AlignmentType.LEFT, style: { paragraph: { indent: { left: 720, hanging: 360 } } } },
        { level: 1, format: LevelFormat.BULLET, text: "+", alignment: AlignmentType.LEFT, style: { paragraph: { indent: { left: 1260, hanging: 360 } } } },
      ] },
      { reference: "numbers", levels: [
        { level: 0, format: LevelFormat.DECIMAL, text: "%1.", alignment: AlignmentType.LEFT, style: { paragraph: { indent: { left: 720, hanging: 360 } } } },
      ] },
    ],
  },

  sections: [
    { // bìa: không đánh số trang, có khung viền đôi
      properties: { page: { margin: margins, borders: {
        pageBorders: { display: PageBorderDisplay.ALL_PAGES, offsetFrom: PageBorderOffsetFrom.TEXT },
        pageBorderTop: dbl, pageBorderBottom: dbl, pageBorderLeft: dbl, pageBorderRight: dbl } } },
      children: cover(),
    },
    { // phần đầu: số trang i, ii, iii…
      properties: { page: { margin: margins, pageNumbers: { start: 1, formatType: NumberFormat.LOWER_ROMAN } } },
      footers: { default: pageFooter },
      children: frontBlocks,
    },
    { // nội dung chính: số trang 1, 2, 3…
      properties: { page: { margin: margins, pageNumbers: { start: 1, formatType: NumberFormat.DECIMAL } } },
      headers: { default: new Header({ children: [new Paragraph({ alignment: AlignmentType.RIGHT,
        border: { bottom: { style: BorderStyle.SINGLE, size: 4, color: "808080", space: 1 } },
        children: [new TextRun({ text: "Đồ án Cơ Sở Dữ Liệu Nâng Cao – Phân mảnh hỗn hợp trong CSDL phân tán", italics: true, size: 20 })] })] }) },
      footers: { default: pageFooter },
      children: mainBlocks,
    },
  ],
});

Packer.toBuffer(doc).then((buf) => {
  fs.writeFileSync(OUT, buf);
  console.log("Đã ghi", OUT);
});
