import '../models/reciter.dart';

class ReciterService {
  static final ReciterService _instance = ReciterService._internal();
  factory ReciterService() => _instance;
  ReciterService._internal();

  final List<Reciter> _reciters = [
    Reciter(id: "Alafasy_128kbps", name: "Mishary Rashid Al-Afasy", bitrate: "128kbps"),
    Reciter(id: "Abdurrahmaan_As-Sudais_192kbps", name: "Abdurrahman As-Sudais", bitrate: "192kbps"),
    Reciter(id: "Ghamadi_40kbps", name: "Saad al-Ghamdi", bitrate: "40kbps"),
    Reciter(id: "Minshawi_Murattal_128kbps", name: "Muhammad Siddiq al-Minshawi", style: "Murattal", bitrate: "128kbps"),
    Reciter(id: "Saood_ash-Shuraym_128kbps", name: "Saoud ash-Shuraym", bitrate: "128kbps"),
    Reciter(id: "Mansour_Al_Salimi_128kbps", name: "Mansour Al-Salimi", bitrate: "128kbps"),
    Reciter(id: "Mohammad_al_Tablaway_128kbps", name: "Mohammad al-Tablaway", bitrate: "128kbps"),
    Reciter(id: "Abdul_Basit_Murattal_64kbps", name: "Abdul Basit Abdus Samad", style: "Murattal", bitrate: "64kbps"),
    Reciter(id: "Abdul_Basit_Murattal_192kbps", name: "Abdul Basit Abdus Samad", style: "Murattal", bitrate: "192kbps"),
    Reciter(id: "Abdul_Basit_Mujawwad_128kbps", name: "Abdul Basit Abdus Samad", style: "Mujawwad", bitrate: "128kbps"),
    Reciter(id: "Abu_Bakr_Ash-Shaatree_128kbps", name: "Abu Bakr Ash-Shaatree", bitrate: "128kbps"),
    Reciter(id: "Ahmed_ibn_Ali_al-Ajmy_128kbps", name: "Ahmed ibn Ali al-Ajmy", bitrate: "128kbps"),
    Reciter(id: "Ahmed_ibn_Ali_al-Ajmy_64kbps", name: "Ahmed ibn Ali al-Ajmy", bitrate: "64kbps"),
    Reciter(id: "Hani_Rifai_192kbps", name: "Hani ar-Rifai", bitrate: "192kbps"),
    Reciter(id: "Husary_128kbps", name: "Mahmoud Khalil al-Husary", bitrate: "128kbps"),
    Reciter(id: "Husary_Muallim_128kbps", name: "Mahmoud Khalil al-Husary", style: "Muallim", bitrate: "128kbps"),
    Reciter(id: "Husary_Mujawwad_128kbps", name: "Mahmoud Khalil al-Husary", style: "Mujawwad", bitrate: "128kbps"),
    Reciter(id: "Hudhaify_128kbps", name: "Ali Al-Huthaifi", bitrate: "128kbps"),
    Reciter(id: "Ibrahim_Akhdar_32kbps", name: "Ibrahim al-Akhdar", bitrate: "32kbps"),
    Reciter(id: "Maher_AlMuaiqly_128kbps", name: "Maher al-Muaiqly", bitrate: "128kbps"),
    Reciter(id: "Menshawi_Mujawwad_128kbps", name: "Muhammad Siddiq al-Minshawi", style: "Mujawwad", bitrate: "128kbps"),
    Reciter(id: "Muhammad_Ayyoub_128kbps", name: "Muhammad Ayyoub", bitrate: "128kbps"),
    Reciter(id: "Muhammad_Jibreel_128kbps", name: "Muhammad Jibreel", bitrate: "128kbps"),
    Reciter(id: "Nasser_Alqatami_128kbps", name: "Nasser Al-Qatami", bitrate: "128kbps"),
    Reciter(id: "Parhizgar_48kbps", name: "Shahriar Parhizgar", bitrate: "48kbps"),
    Reciter(id: "Salah_Al_Budair_128kbps", name: "Salah al-Budair", bitrate: "128kbps"),
    Reciter(id: "Yasser_Ad-Dussary_128kbps", name: "Yasser ad-Dossari", bitrate: "128kbps"),
    Reciter(id: "Abdullah_Basfar_192kbps", name: "Abdullah Basfar", bitrate: "192kbps"),
    Reciter(id: "Abdul_Rashid_Sufi_128kbps", name: "Abdul Rashid Sufi", bitrate: "128kbps"),
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
