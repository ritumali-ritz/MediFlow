import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/location_model.dart';
import '../../utils/theme.dart';
import '../patient/clinic_search.dart';

class LocationSelectorScreen extends StatefulWidget {
  const LocationSelectorScreen({super.key});

  @override
  State<LocationSelectorScreen> createState() => _LocationSelectorScreenState();
}

class _LocationSelectorScreenState extends State<LocationSelectorScreen> {
  String? selectedDistrict;
  String? selectedTehsil;

  // Complete Maharashtra data - All 36 districts with their tehsils
  final Map<String, List<String>> maharashtraData = {
    "Ahmednagar": ["Ahmednagar", "Akole", "Jamkhed", "Karjat", "Kopargaon", "Nagar", "Nevasa", "Parner", "Pathardi", "Rahata", "Rahuri", "Sangamner", "Shevgaon", "Shrigonda", "Shrirampur"],
    "Akola": ["Akola", "Akot", "Balapur", "Barshitakli", "Murtizapur", "Patur", "Telhara"],
    "Amravati": ["Achalpur", "Amravati", "Anjangaon Surji", "Bhatkuli", "Chandur Railway", "Chandurbazar", "Chikhaldara", "Daryapur", "Dharni", "Dhamangaon Railway", "Morshi", "Nandgaon Khandeshwar", "Teosa", "Warud"],
    "Aurangabad": ["Aurangabad", "Gangapur", "Kannad", "Khuldabad", "Paithan", "Phulambri", "Sillod", "Soegaon", "Vaijapur"],
    "Beed": ["Ambajogai", "Ashti", "Beed", "Dharur", "Georai", "Kaij", "Majalgaon", "Parli", "Patoda", "Shirur-Kasar", "Wadwani"],
    "Bhandara": ["Bhandara", "Lakhani", "Mohadi", "Pauni", "Sakoli", "Tumsar"],
    "Buldhana": ["Buldana", "Chikhli", "Deulgaon Raja", "Jalgaon Jamod", "Khamgaon", "Lonar", "Malkapur", "Mehkar", "Motala", "Nandura", "Sangrampur", "Shegaon", "Sindkhed Raja"],
    "Chandrapur": ["Ballarpur", "Bhadravati", "Bramhapuri", "Chandrapur", "Chimur", "Gondpipri", "Jivati", "Korpana", "Mul", "Nagbhir", "Pombhurna", "Rajura", "Saoli", "Sindewahi", "Warora"],
    "Dhule": ["Dhule", "Sakri", "Shirpur", "Sindkhede"],
    "Gadchiroli": ["Aheri", "Armori", "Bhamragad", "Chamorshi", "Desaiganj", "Dhanora", "Etapalli", "Gadchiroli", "Korchi", "Kurkheda", "Mulchera", "Sironcha"],
    "Gondia": ["Amgaon", "Arjuni Morgaon", "Deori", "Goregaon", "Gondia", "Sadak Arjuni", "Salekasa", "Tirora"],
    "Hingoli": ["Aundha Nagnath", "Basmath", "Hingoli", "Kalamnuri", "Sengaon"],
    "Jalgaon": ["Amalner", "Bhadgaon", "Bhusawal", "Bodwad", "Chalisgaon", "Chopda", "Dharangaon", "Erandol", "Jalgaon", "Jamner", "Muktainagar", "Pachora", "Parola", "Raver", "Yawal"],
    "Jalna": ["Ambad", "Badnapur", "Bhokardan", "Ghansawangi", "Jafferabad", "Jalna", "Mantha", "Partur"],
    "Kolhapur": ["Ajra", "Bavda", "Bhudargad", "Chandgad", "Gadhinglaj", "Hatkanangle", "Kagal", "Karvir", "Panhala", "Radhanagari", "Shahuwadi", "Shirol"],
    "Latur": ["Ahmadpur", "Ausa", "Chakur", "Deoni", "Jalkot", "Latur", "Nilanga", "Renapur", "Shirur-Anantpal", "Udgir"],
    "Mumbai City": ["Mumbai City"],
    "Mumbai Suburban": ["Andheri", "Borivali", "Kurla"],
    "Nagpur": ["Bhiwapur", "Hingna", "Kalameshwar", "Kamptee", "Katol", "Kuhi", "Mauda", "Nagpur Rural", "Nagpur Urban", "Narkhed", "Parseoni", "Ramtek", "Savner", "Umred"],
    "Nanded": ["Ardhapur", "Bhokar", "Biloli", "Deglur", "Dharmabad", "Hadgaon", "Himayatnagar", "Kandhar", "Kinwat", "Loha", "Mahur", "Mudkhed", "Mukhed", "Naigaon", "Nanded", "Umri"],
    "Nandurbar": ["Akkalkuwa", "Akrani", "Nandurbar", "Nawapur", "Shahade", "Talode"],
    "Nashik": ["Baglan", "Chandvad", "Deola", "Dindori", "Igatpuri", "Kalwan", "Malegaon", "Nandgaon", "Nashik", "Niphad", "Peint", "Sinnar", "Surgana", "Trimbakeshwar", "Yeola"],
    "Osmanabad": ["Bhum", "Kalamb", "Lohara", "Osmanabad", "Paranda", "Tuljapur", "Umarga", "Washi"],
    "Palghar": ["Dahanu", "Jawhar", "Mokhada", "Palghar", "Talasari", "Vasai", "Vikramgad", "Wada"],
    "Parbhani": ["Gangakhed", "Jintur", "Manwath", "Palam", "Parbhani", "Pathri", "Purna", "Sailu", "Sonpeth"],
    "Pune": ["Ambegaon", "Baramati", "Bhor", "Daund", "Haveli", "Indapur", "Junnar", "Khed", "Mawal", "Mulshi", "Pune City", "Purandhar", "Shirur", "Velhe"],
    "Raigad": ["Alibag", "Karjat", "Khalapur", "Mahad", "Mangaon", "Mhasla", "Murud", "Panvel", "Pen", "Poladpur", "Roha", "Shrivardhan", "Sudhagad", "Tala", "Uran"],
    "Ratnagiri": ["Chiplun", "Dapoli", "Guhagar", "Khed", "Lanja", "Mandangad", "Rajapur", "Ratnagiri", "Sangameshwar"],
    "Sangli": ["Atpadi", "Jat", "Kadegaon", "Kavathemahankal", "Khanapur-Vita", "Miraj", "Palus", "Shirala", "Tasgaon", "Walwa"],
    "Satara": ["Jaoli", "Karad", "Khandala", "Khatav", "Koregaon", "Mahabaleshwar", "Man", "Patan", "Phaltan", "Satara", "Wai"],
    "Sindhudurg": ["Devgad", "Dodamarg", "Kankavli", "Kudal", "Malwan", "Sawantwadi", "Vaibhavvadi", "Vengurla"],
    "Solapur": ["Akkalkot", "Barshi", "Karmala", "Madha", "Malshiras", "Mangalvedhe", "Mohol", "Pandharpur", "Sangole", "Solapur North", "Solapur South"],
    "Thane": ["Ambarnath", "Bhiwandi", "Kalyan", "Murbad", "Shahapur", "Thane", "Ulhasnagar"],
    "Wardha": ["Arvi", "Ashti", "Deoli", "Hinganghat", "Karanja", "Samudrapur", "Seloo", "Wardha"],
    "Washim": ["Karanja", "Malegaon", "Mangrulpir", "Manora", "Risod", "Washim"],
    "Yavatmal": ["Arni", "Babulgaon", "Darwha", "Digras", "Ghatanji", "Kalamb", "Kelapur", "Mahagaon", "Maregaon", "Ner", "Pusad", "Ralegaon", "Umarkhed", "Wani", "Yavatmal", "Zari-Jamani"]
  };

  List<String> get tehsilsForDistrict {
    if (selectedDistrict == null) return [];
    return maharashtraData[selectedDistrict!] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Location'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Maharashtra',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Select your district and tehsil',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            
            // District Dropdown
            DropdownButtonFormField<String>(
              value: selectedDistrict,
              decoration: const InputDecoration(
                labelText: 'District',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_city),
              ),
              items: maharashtraData.keys.map((district) {
                return DropdownMenuItem(value: district, child: Text(district));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedDistrict = value;
                  selectedTehsil = null; // Reset tehsil
                });
              },
            ),
            
            const SizedBox(height: 16),
            
            // Tehsil Dropdown
            DropdownButtonFormField<String>(
              value: selectedTehsil,
              decoration: const InputDecoration(
                labelText: 'Tehsil',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.place),
              ),
              items: tehsilsForDistrict.map((tehsil) {
                return DropdownMenuItem(value: tehsil, child: Text(tehsil));
              }).toList(),
              onChanged: selectedDistrict == null ? null : (value) {
                setState(() {
                  selectedTehsil = value;
                });
              },
            ),
            
            const Spacer(),
            
            GradientButton(
              text: 'Find Hospitals',
              icon: Icons.search,
              onPressed: selectedDistrict == null
                  ? null
                  : () {
                      final location = LocationModel(
                        state: 'Maharashtra',
                        district: selectedDistrict!,
                        tehsil: selectedTehsil ?? '',
                      );
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ClinicSearchScreen(location: location),
                        ),
                      );
                    },
            ),
          ],
        ),
      ),
    );
  }
}
