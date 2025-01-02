require 'sinatra'
require 'sqlite3'
require 'erb'

# Inisialisasi database
DB = SQLite3::Database.new 'history.db'
DB.execute <<-SQL
  CREATE TABLE IF NOT EXISTS history (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    gejala TEXT,
    hasil TEXT,
    tanggal TEXT DEFAULT (datetime('now', 'localtime'))  -- menggunakan waktu lokal
  );
SQL

# Menyusun aturan diagnosis
class Pakar
  def initialize
    @aturan = []
  end

  def tambah_aturan(hasil, gejala)
    @aturan << { hasil: hasil, gejala: gejala }
  end

  # Fungsi backward chaining yang lebih ketat
  def diagnosa(gejala_terpilih)
    hasil_hipotesis = []

    # Mencari hasil yang sesuai dengan gejala yang dipilih
    @aturan.each do |aturan|
      # Memeriksa apakah aturan cocok, semua gejala dalam aturan harus ada di gejala yang dipilih
      if (aturan[:gejala] - gejala_terpilih).empty? && (gejala_terpilih - aturan[:gejala]).empty?
        hasil_hipotesis << aturan[:hasil]
      end
    end

    # Jika tidak ada hasil yang cocok
    if hasil_hipotesis.empty?
      hasil_hipotesis = ["Tidak ada diagnosis yang cocok dengan gejala yang Anda pilih. Silakan konsultasikan lebih lanjut."]
    end

    hasil_hipotesis
  end
end


# Menambahkan aturan-aturan diagnosis yang lebih cocok dengan backward chaining
sistem_pakar = Pakar.new
sistem_pakar.tambah_aturan("Demam Berdarah ringan", ["G01", "G02"])
sistem_pakar.tambah_aturan("Demam Berdarah", ["G01", "G04"])
sistem_pakar.tambah_aturan("Demam Berdarah tingkat lanjut", ["G06", "G04"])
sistem_pakar.tambah_aturan("Demam Berdarah Dengue", ["G01", "G03", "G04"])
sistem_pakar.tambah_aturan("DBD ringan atau demam biasa", ["G02", "G07", "G08"])
sistem_pakar.tambah_aturan("DBD berat atau gangguan pencernaan lainnya", ["G06", "G09"])
sistem_pakar.tambah_aturan("Komplikasi DBD berat (perdarahan dalam)", ["G10", "G05"])

# Routing untuk login
get '/login' do
  erb :login
end

post '/login' do
  redirect to('/mulai_diagnosis')
end

# Routing untuk mulai diagnosis
get '/mulai_diagnosis' do
  erb :mulai_diagnosis
end

# Routing untuk menampilkan hasil diagnosis
post '/hasil_diagnosis' do
  # Mengambil semua gejala yang dipilih, yang nilainya 'true', dan menghapus yang 'false'
  gejala_terpilih = params[:gejala].reject { |key, value| value == 'false' }.keys

  # Diagnosis berdasarkan gejala yang dipilih
  hasil_hipotesis = sistem_pakar.diagnosa(gejala_terpilih)

  if hasil_hipotesis.empty?
    @hasil = "Tidak ada diagnosis yang cocok dengan gejala yang Anda pilih."
  else
    @hasil = hasil_hipotesis.join(', ')
  end

  erb :hasil_diagnosis, locals: { hasil: @hasil, gejala: gejala_terpilih.join(', ') }
end







# Routing untuk menyimpan hasil diagnosis ke dalam riwayat
post '/save_history' do
  gejala = params[:gejala].is_a?(Hash) ? params[:gejala].keys.join(", ") : params[:gejala]
  hasil = params[:hasil]
  save_history(gejala, hasil)
  redirect to('/history')
end

# Fungsi untuk menyimpan hasil diagnosis
def save_history(gejala, hasil)
  DB.execute("INSERT INTO history (gejala, hasil) VALUES (?, ?)", [gejala, hasil])
end

# Fungsi untuk memuat riwayat diagnosis
def load_history
  DB.execute("SELECT * FROM history ORDER BY tanggal DESC")
end

# Fungsi untuk menghapus satu riwayat berdasarkan id
def delete_history(id)
  DB.execute("DELETE FROM history WHERE id = ?", [id])
end

# Fungsi untuk menghapus semua riwayat
def delete_all_history
  DB.execute("DELETE FROM history")
end

# Routing untuk halaman utama
get '/' do
  erb :index
end

# Routing untuk halaman riwayat
get '/history' do
  @history = load_history
  erb :history
end

# Routing untuk halaman hasil diagnosis
get '/hasil_diagnosis' do
  erb :hasil_diagnosis  # Menampilkan tampilan hasil
end

# Routing untuk menghapus riwayat berdasarkan id dengan metode POST
post '/delete_history' do
  delete_history(params[:id])  # Menghapus riwayat berdasarkan ID
  redirect to('/history')  # Setelah menghapus, arahkan kembali ke halaman riwayat
end


# Routing untuk menghapus semua riwayat dengan metode POST
post '/delete_all_history' do
  delete_all_history
  redirect to('/history')  # Mengarahkan ke halaman riwayat setelah menghapus
end
