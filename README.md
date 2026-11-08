# Bộ skill làm video cho Claude Code

Đây là bộ skill giúp [Claude Code](https://claude.com/claude-code) dựng video bằng code: video giới thiệu sản phẩm, demo app, hướng dẫn, motion graphics, cảnh 3D. Video có giọng đọc tiếng Việt (nam, miền Bắc) và phụ đề, xuất ra MP4. Cài một lần là dùng được ở mọi dự án. Sau đó chỉ cần mở Claude Code và nói "làm video …".

Engine dựng chính là [Remotion](https://www.remotion.dev) (video viết bằng React). Các thư viện còn lại là lựa chọn thêm khi video cần, Claude tự chọn theo nội dung.

## Có gì trong bộ này

| Nhóm | Skill | Nguồn |
|---|---|---|
| Điểm vào | `video`: bộ công cụ chuẩn, quy trình 6 bước, giọng đọc cố định (`tts.py`, `voice.json`) | repo này |
| Dựng video | 13 skill `remotion-*`: best-practices, create, studio, render, markup, captions, multimedia, interactivity, maps, saas, docs, upgrade, license | [remotion-dev/skills](https://github.com/remotion-dev/skills) |
| | `motion-canvas`: video giải thích khớp theo giọng đọc | repo này |
| Chuyển động | 8 skill `gsap-*`: core, timeline, scrolltrigger, plugins, react, frameworks, performance, utils | [greensock/gsap-skills](https://github.com/greensock/gsap-skills) |
| | `motion` (Motion, trước là Framer Motion) | [motiondivision/ai-kit](https://github.com/motiondivision/ai-kit) |
| | `animejs` (Anime.js v4), `rive` (file .riv) | repo này |
| 3D | `threejs-3d`: Three.js, React Three Fiber, Drei, Rapier, postprocessing | repo này |
| Thiết kế | `svg-design`: Satori (ảnh bìa, thumbnail), SVGO | repo này |
| Âm thanh web | `howler`: chỉ cho trang web tương tác, không dùng cho file video | repo này |

Tổng cộng 29 skill. 7 skill nằm trong thư mục [`skills/`](skills) của repo này: chúng do Claude Code viết theo tài liệu gốc của từng thư viện (kiểm tra 10/2026), vì các thư viện này chưa có skill chính thức. 22 skill còn lại không lưu trong repo: `install.sh` tải bản mới nhất từ repo gốc của nhà phát triển, nên số skill có thể tăng khi bên gốc cập nhật.

## Chuẩn bị

Cần 4 thứ. Mở Terminal và gõ lệnh kiểm tra ở cột bên phải:

| Cần | Kiểm tra | Cài |
|---|---|---|
| Claude Code | `claude --version` | [claude.com/claude-code](https://claude.com/claude-code) |
| Node.js 22.20 trở lên | `node -v` | [nodejs.org](https://nodejs.org), chọn bản LTS |
| git | `git --version` | macOS: `xcode-select --install`; Windows: [git-scm.com](https://git-scm.com) |
| uv (chạy script giọng đọc) | `uv --version` | xem bên dưới |

Cài uv:

```bash
# macOS, Linux
curl -LsSf https://astral.sh/uv/install.sh | sh
```

```powershell
# Windows (PowerShell)
powershell -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"
```

Cài xong thì mở cửa sổ Terminal mới để lệnh `uv` có hiệu lực.

## Cài nhanh (macOS, Linux)

```bash
git clone https://github.com/phido0410/claude-video-skills.git
cd claude-video-skills
./install.sh
```

Script mất vài phút, tùy tốc độ mạng. Nó làm 3 việc:

1. Tải 22 skill chính thức (Remotion, GSAP, Motion) bằng [skills CLI](https://github.com/vercel-labs/skills) vào `~/.claude/skills/`.
2. Chép 7 skill trong `skills/` vào cùng thư mục. Skill nào đã có sẵn trên máy thì bản cũ được chuyển sang `~/.claude/skills-backup-<ngày-giờ>/` trước, không bị mất.
3. Nhắc nếu máy chưa có uv.

Chạy lại script nhiều lần không sao. Mỗi lần chạy là một lần cập nhật.

## Cài từng bước (Windows, hoặc muốn tự cài)

Trên Windows có thể chạy `./install.sh` trong **Git Bash** (cài kèm git). Nếu muốn tự cài thì làm 2 bước dưới. Các lệnh cho Windows viết theo tài liệu, chưa được chạy thử trên máy Windows.

**Bước 1.** Tải 3 bộ skill chính thức. Lệnh giống nhau trên mọi hệ điều hành:

```bash
npx -y skills add remotion-dev/skills --skill '*' -g -a claude-code --copy -y
npx -y skills add greensock/gsap-skills --skill '*' -g -a claude-code --copy -y
npx -y skills add motiondivision/ai-kit --skill '*' -g -a claude-code --copy -y
```

Trong đó `-g` cài cho mọi dự án, `-a claude-code` chỉ cài cho Claude Code, `--copy` chép thẳng tệp thay vì tạo liên kết, `-y` không hỏi lại.

**Bước 2.** Chép 7 skill tự viết. Không có git thì bấm **Code → Download ZIP** trên trang repo, giải nén ra.

```bash
# macOS, Linux
mkdir -p ~/.claude/skills && cp -R skills/* ~/.claude/skills/
```

```powershell
# Windows (PowerShell), chạy trong thư mục repo
New-Item -ItemType Directory -Force "$env:USERPROFILE\.claude\skills" | Out-Null
Copy-Item -Recurse -Force skills\* "$env:USERPROFILE\.claude\skills\"
```

Cài đúng chỗ thì sẽ có tệp `~/.claude/skills/video/SKILL.md` (Windows: `C:\Users\<tên>\.claude\skills\video\SKILL.md`).

## Kiểm tra

1. **Mở phiên Claude Code mới.** Phiên đang mở không thấy skill mới. Trong VS Code thì bấm `Cmd/Ctrl+Shift+P` rồi chọn **Developer: Reload Window**.
2. **Đếm skill**: lệnh này phải ra 29 (hoặc hơn, nếu bên gốc thêm skill).
   ```bash
   ls ~/.claude/skills | grep -cE '^(video|remotion-|gsap-|motion|animejs|howler|rive|svg-design|threejs-3d)'
   ```
3. **Hỏi Claude Code**: gõ `/video`, hoặc hỏi "em có những skill làm video nào?".
4. **Thử giọng đọc**: tạo được tệp `giong-thu/thu.mp3` là đạt.
   ```bash
   echo '[{"id": "thu", "text": "Xin chào, đây là giọng đọc thử."}]' > thu.json
   uv run ~/.claude/skills/video/tts.py thu.json giong-thu
   ```

## Cách dùng

Mở Claude Code ở thư mục bất kỳ và nói muốn làm video gì. Skill `video` sẽ tự được đọc trước, Claude làm theo quy trình:

1. **Chốt yêu cầu**: chỉ hỏi phần còn thiếu, như khổ hình (ngang 16:9, dọc 9:16, vuông 1:1), độ dài, có giọng đọc, nhạc, phụ đề không.
2. **Lên kịch bản**: chia cảnh, mỗi cảnh dùng thư viện nào.
3. **Tạo dự án riêng** cho video đó. Thư viện chỉ cài trong thư mục dự án, không cài vào máy.
4. **Dựng**: mọi chuyển động chạy theo khung hình nên xuất ra lúc nào cũng giống nhau.
5. **Xem trước** trong Remotion Studio (`http://localhost:3000`). Lúc này góp ý để Claude sửa.
6. **Xuất MP4**: Claude kiểm tra độ dài, độ phân giải và tiếng trước khi báo xong.

Ví dụ câu lệnh:

```text
Làm video giới thiệu app của mình, ngang 16:9, khoảng 1 phút 30 giây, giọng đọc kiểu giới thiệu,
không nhạc nền. Lên kịch bản cho mình duyệt trước rồi mới dựng.
```

```text
Đây là video mình quay màn hình lúc cài app: <đường dẫn tệp>. Cắt và tua nhanh cho gọn khoảng 30 giây,
thêm vòng chạm và phóng to chỗ bấm, làm mờ tên nhóm chat.
```

Kinh nghiệm khi làm:

- **Duyệt kịch bản trước khi dựng.** Sửa kịch bản thì nhanh, sửa video đã dựng thì lâu.
- **Đưa cảnh dùng sản phẩm thật**, như video quay màn hình. Claude cắt, tua nhanh, thêm vòng chạm, phóng to chỗ thao tác.
- **Tên tiếng Anh viết liền có thể bị đọc thiếu.** Ví dụ "HelmetCheck" chỉ được đọc là "helmet". Hãy bảo Claude viết tách "Helmet Check" trong lời đọc; phụ đề vẫn giữ cách viết đúng.
- **Thông tin riêng tư** trong video quay màn hình (tên, số điện thoại, nhóm chat) thì nhờ Claude làm mờ.
- **Xem trong Studio trước khi bảo xuất.** Lần xuất đầu tiên, Remotion tự tải thêm trình duyệt dựng hình (Chrome Headless Shell).

## Giọng đọc

Giọng mặc định là `vi-VN-NamMinhNeural` (nam, miền Bắc) của dịch vụ đọc trên Microsoft Edge, tạo bằng [edge-tts](https://github.com/rany2/edge-tts). Không cần tài khoản hay khóa API. Có 3 kiểu đọc, Claude chọn theo loại video:

| Kiểu | Dùng cho | Tốc độ, cao độ |
|---|---|---|
| `huong-dan` (mặc định) | hướng dẫn, từng bước | giữ nguyên |
| `mo-ta` | giới thiệu sản phẩm, quảng bá | nhanh hơn 8%, cao hơn chút |
| `dien-thuyet` | kể chuyện, truyền cảm hứng | chậm hơn 12%, trầm hơn |

Muốn đổi giọng hoặc chỉnh kiểu đọc thì sửa `~/.claude/skills/video/voice.json`. Ví dụ giọng nữ là `vi-VN-HoaiMyNeural`. Xem các giọng có sẵn:

```bash
uvx edge-tts --list-voices | grep vi-VN
```

edge-tts không phải API chính thức của Microsoft. Thỉnh thoảng dịch vụ báo lỗi `NoAudioReceived` khi gọi nhiều lần liên tiếp: chờ một lát rồi chạy lại là được. Nếu một ngày edge-tts ngừng chạy, có thể chuyển sang Azure AI Speech (cùng tên giọng, cần tài khoản Azure).

## Cập nhật

```bash
cd claude-video-skills
git pull
./install.sh
```

Lệnh này lấy bản mới của cả skill chính thức lẫn skill trong repo. Muốn nâng cấp Remotion trong một dự án video đã có thì bảo Claude dùng `/remotion-upgrade`.

## Sao lưu sau khi sửa skill (cho chủ repo)

Sửa skill trên máy (trong `~/.claude/skills/`) xong thì chép ngược vào repo rồi đẩy lên:

```bash
cd ~/claude-video-skills
for s in video animejs howler motion-canvas rive svg-design threejs-3d; do
  rsync -a --delete --exclude .DS_Store ~/.claude/skills/$s/ skills/$s/
done
git add -A && git commit -m "Update video skills" && git push
```

Thêm skill tự viết mới thì thêm tên nó vào danh sách trên. `install.sh` tự cài mọi thư mục trong `skills/`.

## Gỡ cài đặt

```bash
cd ~/.claude/skills
rm -rf video animejs howler motion-canvas rive svg-design threejs-3d motion remotion-* gsap-*
```

Skills CLI còn ghi danh sách skill đã cài ở `~/.agents/.skill-lock.json`. Tệp này không ảnh hưởng gì sau khi đã xóa skill.

## Giấy phép và lưu ý

- **7 skill trong repo này**: giấy phép MIT ([LICENSE](LICENSE)).
- **Skill chính thức**: theo giấy phép của repo gốc. gsap-skills dùng MIT; remotion-dev/skills và motiondivision/ai-kit chưa ghi giấy phép.
- **Remotion** (thư viện dựng video) miễn phí cho cá nhân, công ty tối đa 3 người và tổ chức phi lợi nhuận, kể cả dùng thương mại. Công ty lớn hơn phải mua giấy phép: xem [remotion.dev/docs/license](https://www.remotion.dev/docs/license).
- **Cảnh quay, nhạc, ảnh lấy trên mạng** (Pixabay, Mixkit, Pexels…): đọc giấy phép trước khi đăng video. Ví dụ, giấy phép Pixabay không cho phát tán lại nguyên bản tệp tải về.
- **Skill chạy với toàn quyền của Claude Code** trên máy bạn. Bộ này chỉ gồm hướng dẫn dạng markdown và một script tạo giọng đọc (`skills/video/tts.py`), nhưng bạn vẫn nên đọc qua trước khi cài.
