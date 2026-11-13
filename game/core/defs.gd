class_name Defs
extends RefCounted




const VO: = 0
const TRI: = 1
const QUAN: = 2
const CHINH: = 3
const SX: = 4
const THUONG: = 5
const N_STATS: = 6
const STAT_KEYS: = ["vo", "tri", "quan", "chinh", "sx", "thuong"]
const STAT_NAMES: = ["Võ lực", "Trí lực", "Quân sự", "Chính trị", "Sản xuất", "Thương nghiệp"]
const STAT_SHORT: = ["Võ", "Trí", "Quân", "Chính", "Sản", "Thương"]

const POT_CAP: = 100.0
const POT_HARD_CAP: = 120.0


const GROWTH_BASE: = 0.8
const OFF_FOCUS: = 0.2
const MENTOR_MULT: = 1.6


const NGO_NAMES: = ["", "Ngu độn", "Bình thường", "Thông tuệ", "Dĩnh ngộ", "Thiên túng"]
const NGO_MULT: = [0.0, 0.6, 0.85, 1.0, 1.25, 1.6]
const NGO_WEIGHTS: = [0, 10, 40, 32, 14, 4]

const MOOD_NAMES: = {"phan_chan": "Phấn chấn", "binh_thuong": "Bình thường", "sa_sut": "Sa sút", "suy_sup": "Suy sụp"}
const MOOD_MULT: = {"phan_chan": 1.2, "binh_thuong": 1.0, "sa_sut": 0.6, "suy_sup": 0.1}

const RARITY_NAMES: = ["Thường", "Hiếm", "Sử thi", "Truyền thuyết"]


const AFFINITY: = [
	[0.0, 0.3, 0.6, 0.1, 0.2, 0.0], 
	[0.3, 0.0, 0.6, 0.6, 0.3, 0.3], 
	[0.6, 0.6, 0.0, 0.3, 0.1, 0.1], 
	[0.1, 0.6, 0.3, 0.0, 0.2, 0.4], 
	[0.2, 0.3, 0.1, 0.2, 0.0, 0.4], 
	[0.0, 0.3, 0.1, 0.4, 0.4, 0.0], 
]


const ROLE_ORDER: = ["tuong", "quan_su", "quan_van", "thuong_nhan", "cong_tuong", "ho_ve", "su_than"]
const ROLES: = {
	"tuong": {"name": "Tướng lĩnh", "w": [0.25, 0.15, 0.6, 0.0, 0.0, 0.0]}, 
	"quan_su": {"name": "Quân sư", "w": [0.0, 0.6, 0.4, 0.0, 0.0, 0.0]}, 
	"quan_van": {"name": "Quan văn", "w": [0.0, 0.3, 0.0, 0.7, 0.0, 0.0]}, 
	"thuong_nhan": {"name": "Thương nhân", "w": [0.0, 0.2, 0.0, 0.0, 0.0, 0.8]}, 
	"cong_tuong": {"name": "Công tượng", "w": [0.0, 0.2, 0.0, 0.0, 0.8, 0.0]}, 
	"ho_ve": {"name": "Hộ vệ", "w": [0.9, 0.0, 0.1, 0.0, 0.0, 0.0]}, 
	"su_than": {"name": "Sứ thần", "w": [0.0, 0.3, 0.0, 0.2, 0.0, 0.0], "mi": 0.5}, 
}


const OFFICE_ORDER: = ["thua_tuong", "lai_bo", "ho_bo", "cong_bo", "le_bo", "binh_bo", "dai_tuong", "tuong_quan", "thai_thu", "huyen_lenh", "do_uy"]
const OFFICES: = {
	"thua_tuong": {"name": "Thừa tướng", "roles": ["quan_van"], "weight": 3.0, "count": 1, "military": false}, 
	"lai_bo": {"name": "Lại bộ", "roles": ["quan_van"], "weight": 2.0, "count": 1, "military": false}, 
	"ho_bo": {"name": "Hộ bộ", "roles": ["thuong_nhan", "quan_van"], "weight": 2.0, "count": 1, "military": false}, 
	"cong_bo": {"name": "Công bộ", "roles": ["cong_tuong"], "weight": 2.0, "count": 1, "military": false}, 
	"le_bo": {"name": "Lễ bộ", "roles": ["su_than"], "weight": 2.0, "count": 1, "military": false}, 
	"binh_bo": {"name": "Binh bộ", "roles": ["quan_su", "tuong"], "weight": 2.0, "count": 1, "military": true}, 
	"dai_tuong": {"name": "Đại tướng quân", "roles": ["tuong"], "weight": 2.5, "count": 1, "military": true}, 
	"tuong_quan": {"name": "Tướng quân", "roles": ["tuong"], "weight": 1.5, "count": 3, "military": true}, 
	"thai_thu": {"name": "Thái thú", "roles": ["quan_van"], "weight": 1.0, "count": 0, "military": false, "per_city": true}, 
	"huyen_lenh": {"name": "Huyện lệnh", "roles": ["quan_van", "thuong_nhan"], "weight": 0.6, "count": 0, "military": false, "per_city": true}, 
	"do_uy": {"name": "Đô úy", "roles": ["tuong", "ho_ve"], "weight": 0.6, "count": 0, "military": true, "per_city": true}, 
}


const ENVS: = {
	"": {"name": "Không có", "stats": [], "mult": 1.0, "cost": 0}, 
	"quan_doanh": {"name": "Quân doanh", "stats": [0, 2], "mult": 1.3, "cost": 10}, 
	"hoc_vien": {"name": "Học viện", "stats": [1, 3], "mult": 1.3, "cost": 15}, 
	"thuong_hoi": {"name": "Thương hội", "stats": [5], "mult": 1.3, "cost": 10}, 
	"cong_xuong": {"name": "Công xưởng", "stats": [4], "mult": 1.3, "cost": 10}, 
	"trieu_dinh": {"name": "Triều đình", "stats": [3, 1], "mult": 1.3, "cost": 0}, 
	"chien_truong": {"name": "Chiến trường", "stats": [0, 2], "mult": 1.6, "cost": 0}, 
	"van_dan": {"name": "Văn đàn, tửu lâu", "stats": [3], "mult": 1.3, "cost": 20}, 
}


const PROFESSIONS: = {
	"nong_dan": {"name": "Nông dân", "focus": [4], "env": "", "w": 30, "city": "sx"}, 
	"ngu_dan": {"name": "Ngư dân", "focus": [4], "env": "", "w": 6, "city": "kinh_te"}, 
	"tho_thu_cong": {"name": "Thợ thủ công", "focus": [4], "env": "cong_xuong", "w": 10, "city": "sx"}, 
	"tho_ren": {"name": "Thợ rèn", "focus": [4, 0], "env": "cong_xuong", "w": 5, "city": "quan_su"}, 
	"tieu_thuong": {"name": "Tiểu thương", "focus": [5], "env": "", "w": 14, "city": "kinh_te"}, 
	"thuong_nhan": {"name": "Thương nhân", "focus": [5, 1], "env": "thuong_hoi", "w": 6, "city": "kinh_te"}, 
	"binh_si": {"name": "Binh sĩ", "focus": [0, 2], "env": "quan_doanh", "w": 12, "city": "quan_su"}, 
	"vo_sinh": {"name": "Võ sinh", "focus": [0], "env": "", "w": 5, "city": "quan_su"}, 
	"kiem_khach": {"name": "Kiếm khách", "focus": [0], "env": "", "w": 2, "city": "quan_su"}, 
	"thu_sinh": {"name": "Thư sinh", "focus": [1, 3], "env": "hoc_vien", "w": 10, "city": "giao_duc"}, 
	"lai_vien": {"name": "Lại viên", "focus": [3], "env": "", "w": 6, "city": "giao_duc"}, 
	"thay_thuoc": {"name": "Thầy thuốc", "focus": [1], "env": "", "w": 4, "city": "giao_duc"}, 
	"phu_khuan_vac": {"name": "Phu khuân vác", "focus": [], "env": "", "w": 10, "city": "kinh_te"}, 
	"nghe_nhan": {"name": "Nghệ nhân", "focus": [3], "env": "van_dan", "w": 3, "city": "kinh_te"}, 
	"bien_si": {"name": "Biện sĩ", "focus": [3, 1], "env": "van_dan", "w": 2, "city": "giao_duc"}, 
	"dan_thuong": {"name": "Dân thường", "focus": [], "env": "", "w": 0, "city": ""}, 
	"quy_toc": {"name": "Công tử thế gia", "focus": [1, 3], "env": "hoc_vien", "w": 0, "city": ""}, 
	"quan_lai": {"name": "Quan văn", "focus": [3, 1], "env": "trieu_dinh", "w": 0, "city": ""}, 
	"vo_quan": {"name": "Võ quan", "focus": [2, 0], "env": "quan_doanh", "w": 0, "city": ""}, 
	"tan_khoa": {"name": "Tân khoa tiến sĩ", "focus": [1, 3], "env": "hoc_vien", "w": 0, "city": ""}, 
	"vo_cu_nhan": {"name": "Võ cử nhân", "focus": [0, 2], "env": "quan_doanh", "w": 0, "city": ""}, 
	"cuu_quan": {"name": "Cựu quan", "focus": [3], "env": "", "w": 0, "city": ""}, 
	"lao_than": {"name": "Lão thần", "focus": [], "env": "", "w": 0, "city": ""}, 
	"muu_si": {"name": "Mưu sĩ", "focus": [1, 2], "env": "", "w": 0, "city": ""}, 
	"vo_su": {"name": "Võ sư", "focus": [1], "env": "", "w": 0, "city": ""}, 
	"thay_day": {"name": "Thầy đồ", "focus": [1], "env": "", "w": 0, "city": ""}, 
	"an_si": {"name": "Ẩn sĩ", "focus": [1], "env": "", "w": 0, "city": ""}, 
}


const CHARM_WEIGHT: = 0.25
const SNUB_BELOW: = 25.0



const FEATURES: = {
	"hoc_phu": {"name": "Học phủ", "desc": "sinh nhiều nhân tài văn; tu dưỡng Trí lực, Chính trị được thêm 30%; dễ tìm danh sư"}, 
	"vo_duong": {"name": "Võ đường", "desc": "sinh nhiều võ nhân; tu dưỡng Võ lực, Quân sự được thêm 30%; dễ tìm danh sư"}, 
	"mo_sat": {"name": "Mỏ sắt", "desc": "chế tác binh khí ở đây +15 tay nghề; chợ luôn bán binh khí tốt"}, 
	"xuong_lua": {"name": "Xưởng lụa", "desc": "chế tác y phục ở đây +15 tay nghề; chợ luôn bán y phục tốt"}, 
	"bai_ngua": {"name": "Bãi ngựa", "desc": "chế tác tọa kỵ ở đây +15 tay nghề; chợ luôn bán ngựa tốt"}, 
	"cang": {"name": "Bến cảng", "desc": "có chợ; sinh nhiều thương nhân; có đường thủy"}, 
	"cua_ai": {"name": "Cửa ải", "desc": "khó công phá (thủ thành ×1,25)"}, 
	"y_quan": {"name": "Y quán", "desc": "sinh nhiều thầy thuốc; nghỉ hết tháng ở đây hồi thêm 10 Sức khỏe"}, 
	"tram_dich": {"name": "Trạm dịch", "desc": "cử người Thăm dò từ đây, tin về sớm hơn 1 tháng"}, 
}

const FEATURE_BIAS: = {
	"hoc_phu": {"stats": {1: 3.0, 3: 3.0}, "profs": ["thu_sinh", "lai_vien", "thay_thuoc"]}, 
	"vo_duong": {"stats": {0: 4.0, 2: 1.0}, "profs": ["vo_sinh", "kiem_khach"]}, 
	"mo_sat": {"stats": {4: 2.0, 0: 1.0}, "profs": ["tho_ren", "tho_thu_cong"]}, 
	"xuong_lua": {"stats": {4: 2.0, 5: 1.0}, "profs": ["tho_thu_cong", "tieu_thuong"]}, 
	"bai_ngua": {"stats": {0: 1.0, 2: 2.0}, "profs": ["binh_si"]}, 
	"cang": {"stats": {5: 3.0}, "profs": ["thuong_nhan", "ngu_dan", "phu_khuan_vac"]}, 
	"cua_ai": {"stats": {2: 2.0}, "profs": ["binh_si"]}, 
	"y_quan": {"stats": {1: 2.0}, "profs": ["thay_thuoc"]}, 
	"tram_dich": {"stats": {5: 1.0, 3: 1.0}, "profs": ["tieu_thuong", "lai_vien"]}, 
}

const TIER_NAMES: = ["Công khai", "Sơ cấp", "Trung cấp", "Cao cấp", "Tối cao"]
const TIER_COST: = [0, 1, 2, 4, 7]
const TIER_W_REAL: = [20.0, 8.0, 3.0, 0.0, 0.0]
const TIER_W_POT: = [-1.0, -1.0, 12.0, 5.0, 0.0]
const TIER_PEN: = [0.0, 20.0, 40.0, 70.0, 95.0]
const TIER_MAX_RARITY: = [-1, -1, 1, 2, 3]


const DESTINY_STARS: = ["Thất Sát", "Văn Khúc", "Phá Quân", "Tử Vi", "Thiên Công", "Lộc Tồn", "Đào Hoa"]
const DESTINY_HINT: = ["Võ lực", "Trí lực", "Quân sự", "Chính trị", "Sản xuất", "Thương nghiệp", "Mị lực"]


static func stat_index(key: String) -> int:
	return STAT_KEYS.find(key)


static func grade(v: float) -> String:
	if v >= 100.0:
		return "Truyền kỳ"
	if v >= 90.0:
		return "Tuyệt thế"
	if v >= 75.0:
		return "Thiên tài"
	if v >= 60.0:
		return "Xuất sắc"
	if v >= 40.0:
		return "Khá"
	if v >= 20.0:
		return "Bình thường"
	return "Kém"



static func age_growth(stat: int, age: int) -> float:
	if age < 12:
		return 0.3
	match stat:
		VO:
			if age <= 17:
				return 1.2
			if age <= 30:
				return 1.0
			if age <= 40:
				return 0.5
			return 0.0
		QUAN:
			if age < 22:
				return 0.7
			if age <= 50:
				return 1.0
			if age <= 65:
				return 0.5
			return 0.0
		TRI:
			if age <= 20:
				return 1.1
			if age <= 60:
				return 1.0
			if age <= 70:
				return 0.5
			return 0.0
		CHINH:
			if age < 25:
				return 0.7
			if age <= 60:
				return 1.0
			if age <= 70:
				return 0.5
			return 0.0

	if age < 16:
		return 0.7
	if age <= 55:
		return 1.0
	return 0.5



static func age_decline(stat: int, age: int) -> float:
	match stat:
		VO:
			return 0.15 if age > 45 else 0.0
		QUAN, TRI, CHINH:
			return 0.05 if age > 65 else 0.0
	return 0.03 if age > 70 else 0.0


static func prof_name(pid: String) -> String:
	return str(PROFESSIONS.get(pid, {"name": pid})["name"])
