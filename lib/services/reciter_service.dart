import '../models/reciter.dart';

class ReciterService {
  static final ReciterService _instance = ReciterService._internal();
  factory ReciterService() => _instance;
  ReciterService._internal();

  final List<Reciter> _reciters = [
    Reciter(id: "Alafasy_128kbps", name: "مشاری ڕاشد العفاسی", bitrate: "128kbps"),
    Reciter(id: "Abdurrahmaan_As-Sudais_192kbps", name: "عبدالرحمن السدیس", bitrate: "192kbps"),
    Reciter(id: "Ghamadi_40kbps", name: "سعد الغامدی", bitrate: "40kbps"),
    Reciter(id: "Minshawi_Murattal_128kbps", name: "محمد صدیق المنشاوی (مورتەل)", style: "Murattal", bitrate: "128kbps"),
    Reciter(id: "Saood_ash-Shuraym_128kbps", name: "سعود الشریم", bitrate: "128kbps"),
    Reciter(id: "Mansour_Al_Salimi_128kbps", name: "منصور السالمی", bitrate: "128kbps"),
    Reciter(id: "Mohammad_al_Tablaway_128kbps", name: "محمد الطبلاوی", bitrate: "128kbps"),
    Reciter(id: "Abdul_Basit_Murattal_64kbps", name: "عبدالباسط عبدالصمد (مورتەل)", style: "Murattal", bitrate: "64kbps"),
    Reciter(id: "Abdul_Basit_Murattal_192kbps", name: "عبدالباسط عبدالصمد (مورتەل)", style: "Murattal", bitrate: "192kbps"),
    Reciter(id: "Abdul_Basit_Mujawwad_128kbps", name: "عبدالباسط عبدالصمد (موجەوەد)", style: "Mujawwad", bitrate: "128kbps"),
    Reciter(id: "Abu_Bakr_Ash-Shaatree_128kbps", name: "أبو بکر الشاطری", bitrate: "128kbps"),
    Reciter(id: "Ahmed_ibn_Ali_al-Ajmy_128kbps", name: "أحمد بن علی العجمی", bitrate: "128kbps"),
    Reciter(id: "Ahmed_ibn_Ali_al-Ajmy_64kbps", name: "أحمد بن علی العجمی", bitrate: "64kbps"),
    Reciter(id: "Hani_Rifai_192kbps", name: "هانی الرفاعی", bitrate: "192kbps"),
    Reciter(id: "Husary_128kbps", name: "محمود خلیل الحصری", bitrate: "128kbps"),
    Reciter(id: "Husary_Muallim_128kbps", name: "محمود خلیل الحصری (مامۆستا)", style: "Muallim", bitrate: "128kbps"),
    Reciter(id: "Husary_Mujawwad_128kbps", name: "محمود خلیل الحصری (موجەوەد)", style: "Mujawwad", bitrate: "128kbps"),
    Reciter(id: "Hudhaify_128kbps", name: "علی الحذیفی", bitrate: "128kbps"),
    Reciter(id: "Ibrahim_Akhdar_32kbps", name: "إبراهیم الأخضر", bitrate: "32kbps"),
    Reciter(id: "Maher_AlMuaiqly_128kbps", name: "ماهر المعیقلی", bitrate: "128kbps"),
    Reciter(id: "Menshawi_Mujawwad_128kbps", name: "محمد صدیق المنشاوی (موجەوەد)", style: "Mujawwad", bitrate: "128kbps"),
    Reciter(id: "Muhammad_Ayyoub_128kbps", name: "محمد أیوب", bitrate: "128kbps"),
    Reciter(id: "Muhammad_Jibreel_128kbps", name: "محمد جبریل", bitrate: "128kbps"),
    Reciter(id: "Nasser_Alqatami_128kbps", name: "ناصر القطامی", bitrate: "128kbps"),
    Reciter(id: "Parhizgar_48kbps", name: "شهریار پرهیزگار", bitrate: "48kbps"),
    Reciter(id: "Salah_Al_Budair_128kbps", name: "صلاح البدیر", bitrate: "128kbps"),
    Reciter(id: "Yasser_Ad-Dussary_128kbps", name: "یاسر الدوسری", bitrate: "128kbps"),
    Reciter(id: "Abdullah_Basfar_192kbps", name: "عبدالله بصفر", bitrate: "192kbps"),
    Reciter(id: "Abdul_Rashid_Sufi_128kbps", name: "عبدالرشید صوفی", bitrate: "128kbps"),
  ];

  List<Reciter> get allReciters => List.unmodifiable(_reciters);

  List<Reciter> search(String query) {
    if (query.isEmpty) return allReciters;
    final lowercaseQuery = query.toLowerCase();
    return _reciters.where((r) => 
      r.name.toLowerCase().contains(lowercaseQuery) || 
      r.id.toLowerCase().contains(lowercaseQuery)
    ).toList();
  }

  Reciter getById(String id) {
    return _reciters.firstWhere((r) => r.id == id, orElse: () => _reciters.first);
  }
}

