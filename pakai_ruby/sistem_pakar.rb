class SistemPakarDBD
  def initialize
    @gejala = {}
    @aturan = []
  end

  # Menambah gejala
  def tambah_gejala(kode, deskripsi)
    @gejala[kode] = deskripsi
  end

  # Menambah aturan
  def tambah_aturan(gejala_list, hasil_diagnosis)
    @aturan << { gejala: gejala_list, diagnosis: hasil_diagnosis }
  end

  # Fungsi backward chaining untuk diagnosis
  def backward_chaining(tujuan, gejala_terpilih)
    # Periksa apakah tujuan sudah ditemukan
    hasil_diagnosis = nil
    @aturan.each do |aturan|
      # Jika aturan cocok dengan gejala yang dipilih
      if (aturan[:gejala] - gejala_terpilih).empty?
        hasil_diagnosis = aturan[:diagnosis]
        break
      end
    end

    if hasil_diagnosis
      puts "Diagnosis: #{hasil_diagnosis}"
    else
      puts "Diagnosis tidak ditemukan. Cek kembali gejala yang dipilih."
    end
  end

  # Menampilkan semua gejala
  def tampilkan_gejala
    puts "Gejala yang tersedia:"
    @gejala.each { |kode, deskripsi| puts "#{kode}: #{deskripsi}" }
  end
end

# Membuat objek sistem pakar DBD
sistem_pakar = SistemPakarDBD.new

# Menambah gejala
sistem_pakar.tambah_gejala("G01", "Demam berlangsung kurang dari 7 hari")
sistem_pakar.tambah_gejala("G02", "Demam hari keempat tubuh terasa lemas")
sistem_pakar.tambah_gejala("G03", "Di lingkungan sekitar ada yang terjangkit DBD")
sistem_pakar.tambah_gejala("G04", "Bintik merah pada tubuh")
sistem_pakar.tambah_gejala("G05", "Pendarahan spontan dalam tubuh (gusi/air seni kemerahan)")
sistem_pakar.tambah_gejala("G06", "Mual muntah")
sistem_pakar.tambah_gejala("G07", "Nyeri kepala")
sistem_pakar.tambah_gejala("G08", "Nyeri sendi")
sistem_pakar.tambah_gejala("G09", "Nyeri ulu hati atau perut bagian atas")
sistem_pakar.tambah_gejala("G10", "Tinja berwarna hitam")

# Menambah aturan
sistem_pakar.tambah_aturan(["G01", "G02"], "Pasien mengalami Demam Berdarah ringan")
sistem_pakar.tambah_aturan(["G01", "G04"], "Pasien mengalami Demam Berdarah")
sistem_pakar.tambah_aturan(["G06", "G04"], "Pasien mengalami Demam Berdarah tingkat lanjut")
sistem_pakar.tambah_aturan(["G01", "G03", "G04"], "Pasien mengalami Demam Berdarah Dengue")
sistem_pakar.tambah_aturan(["G02", "G07", "G08"], "Pasien mengalami DBD ringan atau demam biasa")
sistem_pakar.tambah_aturan(["G06", "G09"], "Pasien mengalami DBD berat atau gangguan pencernaan lainnya")
sistem_pakar.tambah_aturan(["G10", "G05"], "Pasien mengalami komplikasi DBD berat (perdarahan dalam)")

# Menampilkan gejala
sistem_pakar.tampilkan_gejala

# Mengambil input gejala dari pengguna
puts "Masukkan gejala yang dialami (pisahkan dengan koma):"
gejala_input = gets.chomp.split(",").map(&:strip)

# Menggunakan backward chaining untuk menentukan diagnosis
sistem_pakar.backward_chaining(nil, gejala_input)
