class_name Guide
extends RefCounted


const PAGES: = [
	["Bắt đầu", """[font_size=20][color=#d9b064]Tuệ nhãn thức anh hùng[/color][/font_size]
Con mắt tinh nhận ra anh hùng khi họ còn vô danh.

Bạn là con cháu một gia tộc nhỏ, sinh ra với [b]Đôi Mắt Thẩm Định[/b]: nhìn thấu chỉ số, tiềm năng, thiên phú của người khác. Thiên hạ và triều đình chỉ thấy [b]bề ngoài[/b] (Ấn tượng); bạn thấy được [b]người ta có thể trở thành ai[/b].

[color=#d9b064]Vòng chơi chính[/color]
1. [b]Dò la[/b] hoặc ngồi [b]Trà quán[/b] để nghe lời đồn về người trong thành.
2. [b]Tìm gặp[/b] người trong lời đồn, hoặc [b]Gặp gỡ[/b] người đã biết.
3. [b]Thẩm định[/b] bằng Nhãn lực để thấy Thực lực và Tiềm năng; hoặc [b]Quan sát kỹ[/b] (không tốn Nhãn lực, chỉ tốn ngày).
4. Gặp ngọc thô thì [b]Chiêu mộ[/b] làm môn khách, cho [b]Đào tạo[/b] đúng sở trường.
5. Khi đã có thực tài, lên [b]kinh đô Tiến cử[/b] vào triều: nhận thưởng ngay, và mỗi năm được chia công lao của họ.
6. Hết đời thì [b]Trùng sinh[/b]: thế giới như cũ, bạn mang Mệnh cách mới; Thiên Thư nhớ những người đã gặp, Thiên Cơ dùng để nâng cấp.

[color=#d9b064]Tháng đầu nên làm gì[/color]
• Dò la ở thành đang đứng, Tìm gặp người trong lời đồn, thẩm định Sơ cấp / Trung cấp.
• Ai có [b]tiềm năng chữ vàng / cam[/b] mà thực lực còn thấp là ngọc thô: chiêu mộ về.
• Hết Nhãn lực thì Quan sát kỹ, Tĩnh tâm; hết tiền thì Làm thuê, Buôn chuyến.
• Nghỉ hết tháng khi không còn việc đáng làm: thế giới chạy sang tháng mới, có báo cáo."""], 
	["Thời gian & giao diện", """[color=#d9b064]Thời gian[/color]
Mỗi tháng 30 ngày. Mỗi việc tốn vài ngày (ghi trong ngoặc trên nút). Thời gian chỉ trôi khi bạn làm việc; hết 30 ngày thì sang tháng mới, thế giới vận hành (người lớn lên, già đi, đi lại, chiến tranh, triều đình bổ nhiệm…) và bạn nhận [b]báo cáo tháng[/b]. Nút [b]Nghỉ hết tháng[/b] cho thời gian trôi tới đầu tháng sau.
Một số việc không tốn ngày: thẩm định, lưu tâm, ban thưởng, điều môn khách đi (gửi thư).

[color=#d9b064]Màn hình[/color]
• [b]Thanh trên[/b]: tháng, nơi đang ở, ngày, Nhãn lực, ngân lượng, Danh vọng, Gia tộc, Đôi Mắt, chiến sự; Bản đồ, Bản thân, Hệ thống ▾ (lưu, về menu, hướng dẫn, bot tự chơi), [b]Việc chờ[/b] (khi có việc cần bạn quyết), Nghỉ hết tháng.
• [b]Cột trái[/b]: bản đồ nhỏ (bấm thành để đi), khung thành (Kiếm sống…, Quan trường…, Việc nghĩa…, tư trạch, mùa thi), nhật ký.
• [b]Cột giữa[/b]: Tại đây (manh mối, người trong thành), Sổ nhân vật, Môn khách, Triều đình (5 nước), Tin tức, Thế gia.
• [b]Cột phải[/b]: hồ sơ người đang chọn (nút [b]Chi tiết…[/b] mở hồ sơ đầy đủ) và các hành động. Việc phụ nằm trong nút [b]Khác… (n)[/b].
• Chữ [u]gạch chân[/u] có giải thích khi rê chuột lên."""], 
	["Nhìn người", """[color=#d9b064]Ba lớp thông tin về một người[/color]
• [b]Ấn tượng[/b]: điều thiên hạ và triều đình thấy, suy từ nghề, danh tiếng, lời đồn. Khoảng rộng, có thể sai. [b]Triều đình xét tiến cử theo Ấn tượng.[/b]
• [b]Thực[/b]: năng lực hiện tại, Đôi Mắt của bạn thấy khi thẩm định. Tầng càng cao, khoảng càng hẹp.
• [b]Tiềm năng[/b]: mức cao nhất có thể đạt nếu được rèn đúng hướng. Chỉ số ngoài hướng tu dưỡng chỉ lớn ×0,2.

[color=#d9b064]Thẩm định[/color] tốn Nhãn lực (hồi mỗi tháng): Sơ cấp → Trung cấp (thấy tiềm năng, ngộ tính, thiên phú) → Cao cấp (tính cách, trung thành) → Tối cao. Mở tầng cao hơn bằng [b]Ngộ đạo[/b] (thẩm định người mới, nhìn thấu ngụy trang, tiên đoán ứng nghiệm).
[color=#d9b064]Không tốn Nhãn lực[/color]: Quan sát kỹ (thu hẹp Ấn tượng một chỉ số, đôi khi nghe gợi ý), Đàm đạo, Thăm dò (cử người dò tin), bảng điểm mùa thi.

[color=#d9b064]Ngụy trang[/color]
• [b]Ẩn cao nhân[/b]: giỏi mà giấu, Ấn tượng thấp hơn thực nhiều.
• [b]Kẻ hư danh / bị thổi phồng[/b]: tiếng to mà tài mọn. Thẩm định từ Trung cấp có thể nhìn thấu (⚠ Bất thường).
Ngộ tính, thiên phú, tính cách quyết định người ấy lớn nhanh hay chậm, lớn về đâu."""], 
	["Môn khách", """[color=#d9b064]Chiêu mộ[/color] người đã gặp (trong 15 ngày, cùng thành). Khả năng nhận lời theo gia thế, uy tín, Mị lực của bạn, ân tình (Thăm hỏi, Đàm đạo), danh tiếng của họ. Hậu đãi thì dễ hơn.
[color=#d9b064]Chỗ ở[/color]: [b]theo hầu[/b] (đi cùng bạn, số chỗ có hạn, sắm xe ngựa để thêm) hoặc ở [b]tư trạch[/b] (mua nhà ở thành). Điều đi thành khác bằng thư; không có tư trạch thì ở trọ.

[color=#d9b064]Hai ô việc[/color]
• [b]Đào tạo[/b]: Học viện (Trí, Chính), Quân doanh (Võ, Quân), Thương hội, Công xưởng, Giao du văn đàn (Mị). Cần [b]cơ sở ở thành[/b] và phải ở tư trạch.
• [b]Giao việc[/b]: Kinh doanh, Quản gia, Hộ vệ, Thuyết khách (khi theo hầu), Mật thám, Dạy dỗ.
Theo hầu thì làm Hộ vệ / Thuyết khách, về tư trạch thì học tiếp; vừa học vừa làm thì cả hai ×0,75.

[color=#d9b064]Nghề & cây nghề[/color]: làm nghề lâu thì lên bậc, danh xưng đổi theo nhánh hợp sở trường (Tiểu thương → Chủ sạp → Chủ hiệu → Phú thương). Có thể [b]khuyên đổi nghề[/b] hoặc [b]khuyên định hướng[/b].
[color=#d9b064]Trung thành & tiền riêng[/color]: lương, ban thưởng, túi riêng (họ tự sắm đồ, biếu Tết; người tham có thể biển thủ). Trung thành thấp thì dễ bị thế gia khác lôi kéo."""], 
	["Triều đình & tiến cử", """[color=#d9b064]Tiến cử[/color] (ở kinh đô): đưa người vào ghế trống, hoặc thay người đang giữ nếu được [b]chấm cao hơn[/b]. Điểm = năng lực triều đình thấy ở chức đó + danh tiếng + phe phái + dung mạo + thế lực của bạn. Người giữ ghế lâu năm có lợi thế thâm niên.
• Chức cao cần Danh vọng: Thái thú, Tướng quân ≥ 40 · Lục bộ, Đại tướng ≥ 100 · Thừa tướng ≥ 200 (hoặc chính bạn làm quan ngang bậc).
• Mỗi nước mỗi năm nhận 1 + bậc Gia thế lời tiến cử của bạn.
• Thưởng ngay theo điểm; mỗi cuối năm được chia [b]công lao[/b] theo tài thật của họ.

[color=#d9b064]Danh và thực[/color]
• Người Ấn tượng cao mà tài kém làm quan lâu sẽ [b]lộ bất tài[/b], người tiến cử mang tiếng.
• [b]Thi tài[/b] (Danh vọng ≥ 30): cho người tài thật trổ tài ở kinh, triều đình thấy đúng.
• [b]Bảo cử[/b] (≥ 70): cược Danh vọng để triều đình nể mặt.
• [b]Vạch trần[/b] (≥ 50, hoặc là quan lớn hơn): chỉ ra quan bất tài; kết quả có sau vài ngày thẩm tra, có thể bị thế gia đút lót ém đi.

[color=#d9b064]Mùa thi[/color]: 4 năm một khoa, văn võ xen kẽ (năm 1 văn, năm 3 võ…). Tháng 2 thi Hương ở các thành lớn, tháng 3 sĩ tử tụ về kinh thành thi Hội, thi Đình: dịp gặp nhân tài cả nước. Bạn và môn khách đều có thể đi thi."""], 
	["Gia tộc & thế gia", """[color=#d9b064]Gia tộc của bạn[/color]
• [b]Gia thế[/b]: Hàn môn → Thế gia → Danh môn → Hào tộc → Vương tộc (xét đầu năm theo Danh vọng, ngân lượng, môn khách trung thành, người của bạn trong triều). Gia thế cao thì dễ chiêu mộ, được tiến cử nhiều hơn.
• [b]Danh vọng[/b]: tiến cử, việc nghĩa, đỗ đạt, công lao người bạn tiến cử. Mất khi bị lộ âm mưu, tiến cử kẻ bất tài, vu khống.
• [b]Ngân lượng[/b]: thu nhập gia tộc, xưởng, kinh doanh, buôn chuyến, làm thuê; chi lương môn khách, học phí, tư trạch.

[color=#d9b064]Thế gia đối thủ[/color]: các nhà khác cũng săn người, tiến cử, tranh ghế; có nhà dùng âm mưu (thổi phồng, vu cáo, ám sát, hạ độc). Bái phỏng để kết giao (≥ 50 liên minh), hoặc dùng mưu với họ. Thế gia hết người, hết ghế, nợ nần thì sụp đổ.

[color=#d9b064]Bản thân[/color]: Tự tu dưỡng (tối đa 2 lần mỗi tháng), Tĩnh tâm, Kho đồ (binh khí, y phục, tọa kỵ), Xin chức, Theo quân, Chính biến.
[color=#d9b064]Kết thúc[/color]: mỗi đời hướng tới một con đường Thiên mệnh (xem Bản thân → Chi tiết). Hết đời nhận Thiên Cơ để nâng cấp vĩnh viễn."""], 
]


static func open(host: Control, page: int = 0) -> void :
	var body: = UIKit.modal(host, "Hướng dẫn", 980)
	var tc: = TabContainer.new()
	tc.custom_minimum_size = Vector2(950, 600)
	body.add_child(tc)
	for k in PAGES.size():
		var pad: = MarginContainer.new()
		pad.name = "G%d" % k
		for side in ["left", "right", "top", "bottom"]:
			pad.add_theme_constant_override("margin_" + side, 14)
		var r: = UIKit.rich()
		r.scroll_active = true
		r.text = str(PAGES[k][1])
		pad.add_child(r)
		tc.add_child(pad)
		tc.set_tab_title(k, str(PAGES[k][0]))
	tc.current_tab = clampi(page, 0, PAGES.size() - 1)
	var row: = UIKit.hbox(8)
	row.add_child(UIKit.spacer())
	row.add_child(UIKit.button("Đóng", func() -> void : UIKit.close_modal(body)))
	body.add_child(row)
