# controllers/diagnosis_controller.rb
class DiagnosisController < Sinatra::Base
  get '/hasil_diagnosis' do
    @gejala_deskripsi = {
      'G01' => 'Demam berlangsung kurang dari 7 hari',
      'G02' => 'Demam hari keempat tubuh terasa lemas',
      'G03' => 'Di lingkungan sekitar ada yang terjangkit DBD',
      'G04' => 'Bintik merah pada tubuh',
      'G05' => 'Pendarahan spontan dalam tubuh (gusi/air seni kemerahan)',
      'G06' => 'Mual muntah',
      'G07' => 'Nyeri kepala',
      'G08' => 'Nyeri sendi',
      'G09' => 'Nyeri ulu hati atau perut bagian atas',
      'G10' => 'Tinja berwarna hitam'
    }

    erb :hasil_diagnosis
  end
end
