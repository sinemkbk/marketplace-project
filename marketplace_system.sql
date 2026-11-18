
SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Veritabanı: `marketplace_system`
--

DELIMITER $$
--
-- Yordamlar
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_Aylik_Komisyon_Hesapla` (IN `p_Ay` INT, IN `p_Yil` INT)   BEGIN
    -- Elimizdeki mevcut tablolardan verileri çekip anında matematik hesabı yapan aşçımız!
    SELECT 
        sat.Satici_ID,
        sat.Magaza_Adi,
        -- Toplam Satış Tutarı
        SUM(sd.Adet * sd.Satin_Alinan_Fiyat) AS O_Ayki_Toplam_Satis,
        
        -- Kategori_Komisyon tablosundaki orana göre hesaplanan Site Payı
        SUM((sd.Adet * sd.Satin_Alinan_Fiyat) * (kk.Komisyon_Orani / 100)) AS Site_Komisyon_Payi,
        
        -- Satıcıya kalan net tutar
        SUM((sd.Adet * sd.Satin_Alinan_Fiyat) - ((sd.Adet * sd.Satin_Alinan_Fiyat) * (kk.Komisyon_Orani / 100))) AS Saticiya_Kalan_Net_Tutar

    FROM Siparis_Detay sd
    JOIN Siparis s ON sd.Siparis_ID = s.Siparis_ID
    JOIN Siparis_Durum sdurum ON s.Siparis_ID = sdurum.Siparis_ID
    -- Hibrit mimari kancalarımız
    LEFT JOIN Varyant v ON sd.Varyant_ID = v.Varyant_ID
    JOIN Urun u ON (sd.Urun_ID = u.Urun_ID OR v.Urun_ID = u.Urun_ID)
    JOIN Kategori k ON u.Kategori_ID = k.Kategori_ID
    JOIN Kategori_Komisyon kk ON k.Kategori_ID = kk.Kategori_ID
    JOIN Satici sat ON u.Satici_ID = sat.Satici_ID
    
    WHERE 
        -- Sadece 'Teslim edildi' olanlar hesaba katılır
        sdurum.Siparis_Durum = 'Teslim edildi'
        -- Gönderdiğimiz Ay ve Yıl parametrelerine göre Kargo tablosundan filtreleme
        AND MONTH((SELECT Kargo_Verilme_Tarihi FROM Kargo WHERE Siparis_ID = s.Siparis_ID LIMIT 1)) = p_Ay
        AND YEAR((SELECT Kargo_Verilme_Tarihi FROM Kargo WHERE Siparis_ID = s.Siparis_ID LIMIT 1)) = p_Yil
        
    GROUP BY sat.Satici_ID, sat.Magaza_Adi;

END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `Adres`
--

CREATE TABLE `Adres` (
  `Adres_ID` int NOT NULL,
  `Adres_tipi` enum('EV','KURUM','DİĞER') DEFAULT 'EV',
  `Il` varchar(50) NOT NULL,
  `Ilce` varchar(55) NOT NULL,
  `Tam_Adres` text NOT NULL,
  `Musteri_ID` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Tablo döküm verisi `Adres`
--

INSERT INTO `Adres` (`Adres_ID`, `Adres_tipi`, `Il`, `Ilce`, `Tam_Adres`, `Musteri_ID`) VALUES
(1, 'EV', 'Kayseri', 'Melikgazi', 'Üni. Kampüsü No:1', 1),
(2, 'KURUM', 'İstanbul', 'Beşiktaş', 'Felsefe Derneği', 2),
(3, 'KURUM', 'Ankara', 'Çankaya', 'Psiko-Analiz Kliniği', 3),
(4, 'DİĞER', 'Muğla', 'Bodrum', 'Marina Yat Kulübü', 4),
(5, 'EV', 'İzmir', 'Çeşme', 'Sahil Stüdyoları', 5),
(6, 'EV', 'İstanbul', 'Kadıköy', 'Moda Sokak No:10', 6),
(7, 'EV', 'İzmir', 'Karşıyaka', 'Bostanlı Sahili No:15', 7),
(8, 'KURUM', 'Ankara', 'Yenimahalle', 'Teknokent', 8),
(9, 'EV', 'Antalya', 'Kepez', 'Gül Sokak No:8', 9),
(10, 'DİĞER', 'Bursa', 'Osmangazi', 'Kent Meydanı', 10),
(11, 'EV', 'Adana', 'Çukurova', 'Göl Evleri', 11),
(12, 'EV', 'Konya', 'Selçuklu', 'Kampüs Yolu', 12),
(13, 'KURUM', 'Gaziantep', 'Şahinbey', 'Sanayi Bölgesi', 13),
(14, 'EV', 'Kocaeli', 'İzmit', 'Sahil Yolu', 14),
(15, 'EV', 'Mersin', 'Yenişehir', 'Palmiye Sokak', 15),
(16, 'KURUM', 'Diyarbakır', 'Kayapınar', 'İş Merkezi', 16),
(17, 'EV', 'Hatay', 'Antakya', 'Eski Çarşı', 17),
(18, 'EV', 'Eskişehir', 'Odunpazarı', 'Tarihi Evler', 18),
(19, 'DİĞER', 'Samsun', 'Atakum', 'Sahil Sitesi', 19),
(20, 'EV', 'Denizli', 'Pamukkale', 'Traverten Yolu', 20),
(21, 'EV', 'Şanlıurfa', 'Haliliye', 'Balıklıgöl Yanı', 21),
(22, 'KURUM', 'Sakarya', 'Serdivan', 'Üni. Rektörlüğü', 22),
(23, 'EV', 'Manisa', 'Yunusemre', 'Lale Sokak', 23),
(24, 'EV', 'Balıkesir', 'Karesi', 'Merkez Mah.', 24),
(25, 'DİĞER', 'Trabzon', 'Ortahisar', 'Meydan Park', 25),
(26, 'EV', 'Van', 'İpekyolu', 'Göl Manzarası', 26),
(27, 'EV', 'Aydın', 'Efeler', 'Bulvar Üzeri', 27),
(28, 'KURUM', 'Tekirdağ', 'Süleymanpaşa', 'Liman Yolu', 28),
(29, 'EV', 'Kayseri', 'Talas', 'Anayurt Meydan No:5', 29),
(30, 'EV', 'Erzurum', 'Yakutiye', 'Cumhuriyet Cd.', 30),
(31, 'DİĞER', 'Muğla', 'Marmaris', 'Yat Limanı', 31),
(32, 'EV', 'Çanakkale', 'Merkez', 'Kordon Boyu', 32),
(33, 'EV', 'Malatya', 'Battalgazi', 'Yeni Mah.', 33),
(34, 'KURUM', 'Sivas', 'Merkez', 'İstasyon Cd.', 34),
(35, 'EV', 'Batman', 'Merkez', 'Gültepe Mah.', 35),
(36, 'EV', 'Tokat', 'Merkez', 'GOP Bulvarı', 36),
(37, 'DİĞER', 'Zonguldak', 'Merkez', 'Maden Sokak', 37),
(38, 'EV', 'Adıyaman', 'Merkez', 'Gölbaşı Yolu', 38),
(39, 'EV', 'Kütahya', 'Merkez', 'Porsuk Kenarı', 39),
(40, 'KURUM', 'K.Maraş', 'Onikişubat', 'Binevler', 40),
(41, 'EV', 'Çorum', 'Merkez', 'Bahçelievler', 41),
(42, 'EV', 'Osmaniye', 'Merkez', 'Fakıuşağı', 42),
(43, 'DİĞER', 'Isparta', 'Merkez', 'Gül Kent', 43),
(44, 'EV', 'Giresun', 'Merkez', 'Kale Yolu', 44),
(45, 'EV', 'Amasya', 'Merkez', 'Yeşilırmak Kıyısı', 45),
(46, 'KURUM', 'Rize', 'Merkez', 'Çay Tesisi', 46),
(47, 'EV', 'Edirne', 'Merkez', 'Selimiye Civarı', 47),
(48, 'EV', 'Uşak', 'Merkez', 'İsmetpaşa Cd.', 48),
(49, 'DİĞER', 'Yozgat', 'Merkez', 'Üniversite Yanı', 49),
(50, 'EV', 'Kırıkkale', 'Merkez', 'Yeni Mahalle No:1', 50);

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `Degerlendirme`
--

CREATE TABLE `Degerlendirme` (
  `Degerlendirme_ID` int NOT NULL,
  `Puan` int NOT NULL,
  `Yorum` text,
  `Siparis_Detay_ID` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Tablo döküm verisi `Degerlendirme`
--

INSERT INTO `Degerlendirme` (`Degerlendirme_ID`, `Puan`, `Yorum`, `Siparis_Detay_ID`) VALUES
(1, 5, 'Ses kalitesi efsane, baslar çok iyi!', 1),
(2, 5, 'Kesinlikle herkesin okuması gereken bir klasik.', 2);

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `Favoriler`
--

CREATE TABLE `Favoriler` (
  `Favori_ID` int NOT NULL,
  `Eklenme_Tarihi` datetime DEFAULT CURRENT_TIMESTAMP,
  `Urun_ID` int NOT NULL,
  `Musteri_ID` int NOT NULL,
  `Varyant_ID` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Tablo döküm verisi `Favoriler`
--

INSERT INTO `Favoriler` (`Favori_ID`, `Eklenme_Tarihi`, `Urun_ID`, `Musteri_ID`, `Varyant_ID`) VALUES
(1, '2026-05-01 11:27:13', 1, 1, NULL),
(2, '2026-05-01 11:27:13', 28, 2, NULL),
(3, '2026-05-01 11:27:13', 29, 3, NULL),
(4, '2026-05-01 11:27:13', 4, 4, NULL),
(5, '2026-05-01 11:27:13', 20, 5, NULL);

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `Foto_Degerlendirme`
--

CREATE TABLE `Foto_Degerlendirme` (
  `Foto_ID` int NOT NULL,
  `Foto_URL` varchar(255) NOT NULL,
  `Degerlendirme_ID` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Tablo döküm verisi `Foto_Degerlendirme`
--

INSERT INTO `Foto_Degerlendirme` (`Foto_ID`, `Foto_URL`, `Degerlendirme_ID`) VALUES
(1, 'https://site.com/uploads/hoparlor_mutlu_musteri.jpg', 1);

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `Iade`
--

CREATE TABLE `Iade` (
  `Iade_ID` int NOT NULL,
  `Iade_Nedeni` text NOT NULL,
  `Iade_Durumu` enum('Bekliyor','İnceleniyor','Onaylandı','Reddedildi') DEFAULT 'Bekliyor',
  `Iade_adet` int NOT NULL,
  `Iade_Tarihi` datetime DEFAULT CURRENT_TIMESTAMP,
  `Siparis_Detay_ID` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Tablo döküm verisi `Iade`
--

INSERT INTO `Iade` (`Iade_ID`, `Iade_Nedeni`, `Iade_Durumu`, `Iade_adet`, `Iade_Tarihi`, `Siparis_Detay_ID`) VALUES
(1, 'Numarası küçük geldi, sıkıyor.', 'Bekliyor', 1, '2026-05-01 11:27:13', 5);

--
-- Tetikleyiciler `Iade`
--
DELIMITER $$
CREATE TRIGGER `trig_iade_stok_geri_yukle` AFTER UPDATE ON `Iade` FOR EACH ROW BEGIN
    DECLARE satilan_varyant_id INT;
    DECLARE satilan_urun_id INT;

    -- Eğer yönetici İade'yi 'Onaylandı' konumuna getirirse
    IF NEW.Iade_Durumu = 'Onaylandı' AND OLD.Iade_Durumu != 'Onaylandı' THEN
        
        -- Sipariş detayından hangi ürünün satıldığını bul
        SELECT Varyant_ID, Urun_ID INTO satilan_varyant_id, satilan_urun_id
        FROM Siparis_Detay
        WHERE Siparis_Detay_ID = NEW.Siparis_Detay_ID;

        -- EĞER VARYANTLI ÜRÜN İSE
        IF satilan_varyant_id IS NOT NULL THEN
            UPDATE Varyant 
            SET Stok_Sayisi = Stok_Sayisi + NEW.Iade_adet 
            WHERE Varyant_ID = satilan_varyant_id;
            
        -- EĞER VARYANTSIZ ÜRÜN İSE
        ELSEIF satilan_urun_id IS NOT NULL THEN
            UPDATE Urun 
            SET Stok = Stok + NEW.Iade_adet 
            WHERE Urun_ID = satilan_urun_id;
        END IF;
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `Kargo`
--

CREATE TABLE `Kargo` (
  `Kargo_ID` int NOT NULL,
  `Kargo_Firmasi` varchar(100) NOT NULL,
  `Kargo_Verilme_Tarihi` datetime DEFAULT NULL,
  `Kargo_Teslim_Tarihi` datetime DEFAULT NULL,
  `Takip_No` varchar(100) DEFAULT NULL,
  `Siparis_ID` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Tablo döküm verisi `Kargo`
--

INSERT INTO `Kargo` (`Kargo_ID`, `Kargo_Firmasi`, `Kargo_Verilme_Tarihi`, `Kargo_Teslim_Tarihi`, `Takip_No`, `Siparis_ID`) VALUES
(1, 'Yurtiçi Kargo', '2026-05-01 11:27:13', NULL, 'YRT123456789', 1),
(2, 'Aras Kargo', '2026-05-01 11:27:13', NULL, 'ARS987654321', 2),
(3, 'MNG Kargo', '2026-05-01 11:27:13', NULL, 'MNG456789123', 3);

--
-- Tetikleyiciler `Kargo`
--
DELIMITER $$
CREATE TRIGGER `trig_kargo_teslim_durum_guncelle` AFTER UPDATE ON `Kargo` FOR EACH ROW BEGIN
    -- Eğer kargo teslim tarihi daha önce BOŞ iken, şimdi DOLU hale geldiyse
    IF NEW.Kargo_Teslim_Tarihi IS NOT NULL AND OLD.Kargo_Teslim_Tarihi IS NULL THEN
        -- Sipariş durumunu otomatik olarak Teslim edildi yap
        UPDATE Siparis_Durum 
        SET Siparis_Durum = 'Teslim edildi' 
        WHERE Siparis_ID = NEW.Siparis_ID;
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `Kategori`
--

CREATE TABLE `Kategori` (
  `Kategori_ID` int NOT NULL,
  `Kategori_Adi` varchar(200) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Tablo döküm verisi `Kategori`
--

INSERT INTO `Kategori` (`Kategori_ID`, `Kategori_Adi`) VALUES
(1, 'Elektronik'),
(2, 'Bilgisayar & Donanım'),
(3, 'Telefon & Aksesuar'),
(4, 'Giyim & Moda'),
(5, 'Ayakkabı & Çanta'),
(6, 'Kozmetik & Kişisel Bakım'),
(7, 'Kitap & Felsefe'),
(8, 'Kırtasiye & Ofis'),
(9, 'Müzik & Enstrüman'),
(10, 'Ev & Yaşam'),
(11, 'Mobilya & Dekorasyon'),
(12, 'Spor & Outdoor'),
(13, 'Oto & Motosiklet'),
(14, 'Hobi & Oyuncak'),
(15, 'Süpermarket & Gıda');

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `Kategori_Komisyon`
--

CREATE TABLE `Kategori_Komisyon` (
  `Komisyon_ID` int NOT NULL,
  `Komisyon_Orani` decimal(5,2) NOT NULL,
  `Kategori_ID` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Tablo döküm verisi `Kategori_Komisyon`
--

INSERT INTO `Kategori_Komisyon` (`Komisyon_ID`, `Komisyon_Orani`, `Kategori_ID`) VALUES
(1, 5.00, 1),
(2, 5.00, 2),
(3, 4.00, 3),
(4, 15.00, 4),
(5, 12.00, 5),
(6, 18.00, 6),
(7, 8.00, 7),
(8, 10.00, 8),
(9, 12.00, 9),
(10, 10.00, 10),
(11, 14.00, 11),
(12, 9.00, 12),
(13, 7.00, 13),
(14, 11.00, 14),
(15, 5.00, 15);

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `Musteri`
--

CREATE TABLE `Musteri` (
  `Musteri_ID` int NOT NULL,
  `Ad` varchar(100) NOT NULL,
  `Soyad` varchar(100) NOT NULL,
  `Email` varchar(200) NOT NULL,
  `Sifre` varchar(200) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Tablo döküm verisi `Musteri`
--

INSERT INTO `Musteri` (`Musteri_ID`, `Ad`, `Soyad`, `Email`, `Sifre`) VALUES
(1, 'Sinem', 'Kabak', 'sinem@email.com', 'pass123'),
(2, 'Arthur', 'Schopenhauer', 'arthur@email.com', 'felsefe123'),
(3, 'Carl', 'Jung', 'carl@psiko.com', 'bilinc123'),
(4, 'Martin', 'Garrix', 'martin@edm.com', 'drop123'),
(5, 'Shakira', 'Mebarak', 'shakira@latin.com', 'waka123'),
(6, 'Zeynep', 'Kaya', 'zeynep.k@email.com', 'pwd123'),
(7, 'Burak', 'Yılmaz', 'burak.y@email.com', 'pwd123'),
(8, 'Elif', 'Demir', 'elif.d@email.com', 'pwd123'),
(9, 'Kaan', 'Öztürk', 'kaan.o@email.com', 'pwd123'),
(10, 'Ceren', 'Aydın', 'ceren.a@email.com', 'pwd123'),
(11, 'Deniz', 'Çelik', 'deniz.c@email.com', 'pwd123'),
(12, 'Ahmet', 'Şahin', 'ahmet.s@email.com', 'pwd123'),
(13, 'Ayşe', 'Doğan', 'ayse.d@email.com', 'pwd123'),
(14, 'Can', 'Kılıç', 'can.k@email.com', 'pwd123'),
(15, 'Fatma', 'Aslan', 'fatma.a@email.com', 'pwd123'),
(16, 'Mustafa', 'Çetin', 'mustafa.c@email.com', 'pwd123'),
(17, 'Emine', 'Kara', 'emine.k@email.com', 'pwd123'),
(18, 'Ali', 'Koç', 'ali.k@email.com', 'pwd123'),
(19, 'Hatice', 'Kurt', 'hatice.k@email.com', 'pwd123'),
(20, 'Hüseyin', 'Özkan', 'huseyin.o@email.com', 'pwd123'),
(21, 'Merve', 'Şimşek', 'merve.s@email.com', 'pwd123'),
(22, 'Hasan', 'Polat', 'hasan.p@email.com', 'pwd123'),
(23, 'Kübra', 'Öz', 'kubra.o@email.com', 'pwd123'),
(24, 'İbrahim', 'Erdoğan', 'ibrahim.e@email.com', 'pwd123'),
(25, 'Büşra', 'Yavuz', 'busra.y@email.com', 'pwd123'),
(26, 'İsmail', 'Can', 'ismail.c@email.com', 'pwd123'),
(27, 'Esra', 'Güler', 'esra.g@email.com', 'pwd123'),
(28, 'Osman', 'Yıldırım', 'osman.y@email.com', 'pwd123'),
(29, 'Özlem', 'Ak', 'ozlem.a@email.com', 'pwd123'),
(30, 'Halil', 'Güneş', 'halil.g@email.com', 'pwd123'),
(31, 'Pınar', 'Bulut', 'pinar.b@email.com', 'pwd123'),
(32, 'Murat', 'Yıldız', 'murat.y@email.com', 'pwd123'),
(33, 'Gül', 'Avcı', 'gul.a@email.com', 'pwd123'),
(34, 'Volkan', 'Turan', 'volkan.t@email.com', 'pwd123'),
(35, 'Derya', 'Bozkurt', 'derya.b@email.com', 'pwd123'),
(36, 'Gökhan', 'Cengiz', 'gokhan.c@email.com', 'pwd123'),
(37, 'Cemre', 'Sezer', 'cemre.s@email.com', 'pwd123'),
(38, 'Uğur', 'Acar', 'ugur.a@email.com', 'pwd123'),
(39, 'Selin', 'Gök', 'selin.g@email.com', 'pwd123'),
(40, 'Serkan', 'Köse', 'serkan.k@email.com', 'pwd123'),
(41, 'Tuğba', 'Yalçın', 'tugba.y@email.com', 'pwd123'),
(42, 'Emre', 'Taş', 'emre.t@email.com', 'pwd123'),
(43, 'Gizem', 'Akın', 'gizem.a@email.com', 'pwd123'),
(44, 'Okan', 'Uysal', 'okan.u@email.com', 'pwd123'),
(45, 'Melis', 'Gültekin', 'melis.g@email.com', 'pwd123'),
(46, 'Fatih', 'Şen', 'fatih.s@email.com', 'pwd123'),
(47, 'Beren', 'Karakaya', 'beren.k@email.com', 'pwd123'),
(48, 'Kerem', 'Tekin', 'kerem.t@email.com', 'pwd123'),
(49, 'Eda', 'Sarı', 'eda.s@email.com', 'pwd123'),
(50, 'Eren', 'Er', 'eren.e@email.com', 'pwd123');

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `Odeme`
--

CREATE TABLE `Odeme` (
  `Odeme_ID` int NOT NULL,
  `Toplam_Tutar` decimal(10,2) NOT NULL,
  `Siparis_ID` int NOT NULL,
  `Odeme_Tipi_ID` int NOT NULL,
  `Odeme_Tarihi` timestamp NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Tablo döküm verisi `Odeme`
--

INSERT INTO `Odeme` (`Odeme_ID`, `Toplam_Tutar`, `Siparis_ID`, `Odeme_Tipi_ID`, `Odeme_Tarihi`) VALUES
(1, 500.00, 1, 1, '2026-05-04 07:20:47'),
(2, 200.00, 2, 1, '2026-05-04 07:20:47'),
(3, 4500.00, 3, 1, '2026-05-04 07:20:47'),
(4, 1200.00, 4, 1, '2026-05-04 07:20:47'),
(5, 1500.00, 5, 1, '2026-05-04 07:20:47');

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `Odeme_Tipi`
--

CREATE TABLE `Odeme_Tipi` (
  `Odeme_Tipi_ID` int NOT NULL,
  `Odeme_Tipi_Adi` varchar(100) NOT NULL,
  `Aktif_Mi` tinyint(1) DEFAULT '1',
  `Komisyon_Orani` decimal(5,2) DEFAULT '0.00',
  `Odeme_Sistemi_Kodu` varchar(100) DEFAULT NULL,
  `Aciklama` text
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Tablo döküm verisi `Odeme_Tipi`
--

INSERT INTO `Odeme_Tipi` (`Odeme_Tipi_ID`, `Odeme_Tipi_Adi`, `Aktif_Mi`, `Komisyon_Orani`, `Odeme_Sistemi_Kodu`, `Aciklama`) VALUES
(1, 'Kredi Kartı(Tek Çekim)', 1, 0.00, NULL, NULL),
(2, 'Kredi Kartı(Taksit)', 1, 0.00, NULL, NULL),
(3, 'Kapıda Ödeme', 1, 0.00, NULL, NULL),
(4, 'Havale / EFT)', 1, 0.00, NULL, NULL);

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `Satici`
--

CREATE TABLE `Satici` (
  `Satici_ID` int NOT NULL,
  `Magaza_Adi` varchar(200) NOT NULL,
  `Vergi_No` varchar(100) NOT NULL,
  `İletisim` varchar(50) NOT NULL,
  `Satici_Adres` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Tablo döküm verisi `Satici`
--

INSERT INTO `Satici` (`Satici_ID`, `Magaza_Adi`, `Vergi_No`, `İletisim`, `Satici_Adres`) VALUES
(1, 'TeknoMarket', '1111111111', '05551112233', 'İstanbul / Şişli'),
(2, 'ModaVitrini', '2222222222', '05322223344', 'İzmir / Alsancak'),
(3, 'Bilgelik Kitabevi', '3333333333', '05443334455', 'Ankara / Çankaya'),
(4, 'Ritim Müzik', '4444444444', '05334445566', 'Antalya / Muratpaşa'),
(5, 'Evim Şahane', '5555555555', '05055556677', 'Bursa / Nilüfer');

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `Sepet`
--

CREATE TABLE `Sepet` (
  `Sepet_ID` int NOT NULL,
  `Guncelleme_Tarihi` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `Musteri_ID` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Tablo döküm verisi `Sepet`
--

INSERT INTO `Sepet` (`Sepet_ID`, `Guncelleme_Tarihi`, `Musteri_ID`) VALUES
(1, '2026-05-01 11:27:13', 1),
(2, '2026-05-01 11:27:13', 2);

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `Sepet_Detay`
--

CREATE TABLE `Sepet_Detay` (
  `Sepet_Detay_ID` int NOT NULL,
  `Kac_Adet` int NOT NULL DEFAULT '1',
  `Varyant_ID` int DEFAULT NULL,
  `Urun_ID` int DEFAULT NULL,
  `Sepet_ID` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Tablo döküm verisi `Sepet_Detay`
--

INSERT INTO `Sepet_Detay` (`Sepet_Detay_ID`, `Kac_Adet`, `Varyant_ID`, `Urun_ID`, `Sepet_ID`) VALUES
(1, 1, NULL, 10, 1),
(2, 2, 31, NULL, 2);

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `Siparis`
--

CREATE TABLE `Siparis` (
  `Siparis_ID` int NOT NULL,
  `Toplam_Ucret` decimal(10,2) NOT NULL,
  `Siparis_Tarihi` datetime DEFAULT CURRENT_TIMESTAMP,
  `Musteri_ID` int NOT NULL,
  `Adres_ID` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Tablo döküm verisi `Siparis`
--

INSERT INTO `Siparis` (`Siparis_ID`, `Toplam_Ucret`, `Siparis_Tarihi`, `Musteri_ID`, `Adres_ID`) VALUES
(1, 500.00, '2026-05-01 11:27:13', 1, 1),
(2, 200.00, '2026-05-01 11:27:13', 2, 2),
(3, 4500.00, '2026-05-01 11:27:13', 3, 3),
(4, 1200.00, '2026-05-01 11:27:13', 4, 4),
(5, 1500.00, '2026-05-01 11:27:13', 5, 5);

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `Siparis_Detay`
--

CREATE TABLE `Siparis_Detay` (
  `Siparis_Detay_ID` int NOT NULL,
  `Adet` int NOT NULL,
  `Satin_Alinan_Fiyat` decimal(10,2) NOT NULL,
  `Siparis_ID` int NOT NULL,
  `Varyant_ID` int DEFAULT NULL,
  `Urun_ID` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Tablo döküm verisi `Siparis_Detay`
--

INSERT INTO `Siparis_Detay` (`Siparis_Detay_ID`, `Adet`, `Satin_Alinan_Fiyat`, `Siparis_ID`, `Varyant_ID`, `Urun_ID`) VALUES
(1, 1, 500.00, 1, NULL, 1),
(2, 1, 200.00, 2, NULL, 28),
(3, 1, 4500.00, 3, 47, NULL),
(4, 1, 1200.00, 4, 3, NULL),
(5, 1, 1500.00, 5, 24, NULL);

--
-- Tetikleyiciler `Siparis_Detay`
--
DELIMITER $$
CREATE TRIGGER `trig_satis_stok_dus` AFTER INSERT ON `Siparis_Detay` FOR EACH ROW BEGIN
    -- EĞER VARYANTLI ÜRÜN SATILDIYSA
    IF NEW.Varyant_ID IS NOT NULL THEN
        UPDATE Varyant 
        SET Stok_Sayisi = Stok_Sayisi - NEW.Adet 
        WHERE Varyant_ID = NEW.Varyant_ID;
        
    -- EĞER VARYANTSIZ ÜRÜN SATILDIYSA
    ELSEIF NEW.Urun_ID IS NOT NULL THEN
        UPDATE Urun 
        SET Stok = Stok - NEW.Adet 
        WHERE Urun_ID = NEW.Urun_ID;
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `Siparis_Durum`
--

CREATE TABLE `Siparis_Durum` (
  `Siparis_Durum_ID` int NOT NULL,
  `Siparis_Durum` enum('Alındı','Hazırlanıyor','Kargoda','Teslim edildi','İptal') DEFAULT 'Alındı',
  `Siparis_ID` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Tablo döküm verisi `Siparis_Durum`
--

INSERT INTO `Siparis_Durum` (`Siparis_Durum_ID`, `Siparis_Durum`, `Siparis_ID`) VALUES
(1, 'Teslim edildi', 1),
(2, 'Teslim edildi', 2),
(3, 'Kargoda', 3),
(4, 'Hazırlanıyor', 4),
(5, 'Teslim edildi', 5);

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `Urun`
--

CREATE TABLE `Urun` (
  `Urun_ID` int NOT NULL,
  `Urun_Adi` varchar(255) NOT NULL,
  `Urun_Aciklama` text NOT NULL,
  `Satici_ID` int NOT NULL,
  `Kategori_ID` int NOT NULL,
  `Stok` int NOT NULL,
  `onecikan` bigint NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Tablo döküm verisi `Urun`
--

INSERT INTO `Urun` (`Urun_ID`, `Urun_Adi`, `Urun_Aciklama`, `Satici_ID`, `Kategori_ID`, `Stok`, `onecikan`) VALUES
(1, 'Bluetooth Hoparlör', 'Suya dayanıklı taşınabilir', 1, 1, 50, 1),
(2, 'Akıllı Saat X', 'Adımsayar ve nabız ölçer', 1, 1, 0, 1),
(3, '4K Smart LED TV', '50 inç ince kasa', 1, 1, 15, 0),
(4, 'Oyuncu Kulaklığı', '7.1 Surround Sistem', 1, 1, 0, 0),
(5, 'Oyuncu Klavyesi', 'RGB Mekanik Blue Switch', 1, 2, 40, 1),
(6, 'Ergonomik Mouse', 'Kablosuz sessiz tıklama', 1, 2, 0, 0),
(7, '27 inç IPS Monitör', '144Hz 1ms', 1, 2, 25, 1),
(8, '1TB M.2 SSD', '3500MB/s okuma hızı', 1, 2, 80, 0),
(9, 'Laptop Soğutucu', 'Çift sessiz fanlı', 1, 2, 60, 0),
(10, 'Hızlı Şarj Cihazı', '20W PD Type-C', 1, 3, 120, 1),
(11, 'Telefon Kılıfı', 'Silikon şeffaf koruma', 1, 3, 0, 0),
(12, 'Kırılmaz Cam', 'Tam kaplayan 9H dayanıklılık', 1, 3, 0, 0),
(13, 'Oversize Siyah Tişört', '%100 Pamuklu kalın kumaş', 2, 4, 0, 1),
(14, 'Kapşonlu Sweatshirt', 'Kışlık polarlı', 2, 4, 0, 0),
(15, 'Kot Pantolon', 'Skinny Fit esnek kumaş', 2, 4, 0, 0),
(16, 'Deri Ceket', 'Hakiki kuzu derisi', 2, 4, 0, 0),
(17, 'Keten Gömlek', 'Yazlık nefes alan', 2, 4, 0, 1),
(18, 'Spor Ayakkabı', 'Hafif tabanlı yürüyüş ayakkabısı', 2, 5, 0, 0),
(19, 'Klasik Deri Ayakkabı', 'Bağcıklı ofis stili', 2, 5, 0, 0),
(20, 'Topuklu Ayakkabı', '8cm ince topuk', 2, 5, 0, 0),
(21, 'Kadın Kol Çantası', 'Suni deri şık tasarım', 2, 5, 0, 0),
(22, 'Sırt Çantası', 'Su geçirmez laptop bölmeli', 2, 5, 0, 1),
(23, 'C Vitamini Serumu', 'Aydınlatıcı leke karşıtı', 5, 6, 100, 0),
(24, 'Nemlendirici Yüz Kremi', 'Hyalüronik asitli', 5, 6, 80, 1),
(25, 'Mat Ruj Seti', '3 farklı renk tonu', 5, 6, 0, 0),
(26, 'Erkek Parfüm EDP', 'Odunsu ve baharatlı kalıcı', 5, 6, 45, 0),
(27, 'Kadın Parfüm EDT', 'Çiçeksi ve ferah', 5, 6, 50, 0),
(28, 'Schopenhauer - Aşkın Metafiziği', 'Felsefe klasiği', 3, 7, 200, 0),
(29, 'Carl Jung - İnsan ve Sembolleri', 'Psikoloji analizi', 3, 7, 150, 0),
(30, 'Nietzsche - Böyle Söyledi Zerdüşt', 'Başucu kitabı', 3, 7, 300, 0),
(31, 'Dostoyevski - Suç ve Ceza', 'Dünya klasiği', 3, 7, 250, 0),
(32, 'Franz Kafka - Dönüşüm', 'Kısa roman', 3, 7, 400, 0),
(33, 'Kişisel Gelişim Ajandası', 'Tarihsiz motivasyonlu', 3, 8, 0, 0),
(34, 'Dolma Kalem Seti', 'Özel metal kutulu', 3, 8, 30, 0),
(35, 'Çizim Defteri', '120gr kalın dokulu kağıt', 3, 8, 100, 0),
(36, 'Yapışkanlı Not Kağıdı', 'Renkli post-it seti', 3, 8, 500, 0),
(37, 'Fosforlu Kalem 4lü', 'Pastel renkler', 3, 8, 150, 0),
(38, 'Akustik Gitar', 'Başlangıç ve orta seviye', 4, 9, 0, 0),
(39, 'Elektro Gitar', 'Humbucker manyetikli', 4, 9, 0, 0),
(40, 'Gitar Teli Seti', '0.10 paslanmaz çelik', 4, 9, 80, 0),
(41, 'DJ Midi Klavye', '25 tuşlu prodüksiyon aracı', 4, 9, 20, 0),
(42, 'Kondenser Mikrofon', 'Podcast ve yayıncılar için', 4, 9, 40, 0),
(43, 'Filtre Kahve Makinesi', 'Zaman ayarlı programlanabilir', 5, 10, 25, 0),
(44, 'Seramik Kupa Seti', '6lı büyük boy kupalar', 5, 10, 0, 0),
(45, 'Çelik Termos', '24 saat sıcak/soğuk tutar', 5, 10, 0, 0),
(46, 'Bambu Kesme Tahtası', 'Doğal kalın ahşap', 5, 10, 90, 0),
(47, 'Pamuklu Nevresim Takımı', 'Çift kişilik set', 5, 10, 0, 0),
(48, 'Çalışma Masası', 'Metal ayaklı ahşap tabla', 5, 11, 15, 0),
(49, 'Ergonomik Ofis Koltuğu', 'Bel destekli fileli', 5, 11, 0, 0),
(50, 'Kitaplık', '5 raflı modern metal tasarım', 5, 11, 20, 0),
(51, 'TV Ünitesi', 'Duvar raflı ahşap set', 5, 11, 10, 0),
(52, 'Dambıl Seti 20kg', 'Çantalı döküm flanşlı set', 4, 12, 45, 0),
(53, 'Yoga Matı', 'Kaymaz 10mm kalın zemin', 4, 12, 0, 0),
(54, 'Pilates Topu', '65cm şişirme pompalı', 4, 12, 0, 0),
(55, 'Katlanır Kamp Sandalyesi', 'Bardaklıklı taşıma kılıflı', 4, 12, 0, 0),
(56, 'Kamp Çadırı', '3 kişilik tam su geçirmez', 4, 12, 30, 0),
(57, 'Araç İçi Telefon Tutucu', 'Mıknatıslı ızgara uyumlu', 1, 13, 200, 0),
(58, 'Oto Cam Sileceği', 'Telli üniversal ölçü', 1, 13, 100, 0),
(59, 'Motosiklet Kaskı', 'Tam kapalı güneş vizörlü', 1, 13, 0, 0),
(60, 'Motosiklet Brandası', 'Su ve güneş korumalı', 1, 13, 0, 0),
(61, 'Uzaktan Kumandalı Araba', 'Şarjlı off-road süspansiyonlu', 4, 14, 50, 0),
(62, '1000 Parça Puzzle', 'Doğa ve manzara temalı', 4, 14, 120, 0),
(63, 'Kutu Oyunu', 'Strateji ve zeka oyunu', 4, 14, 75, 0),
(64, 'Lego Seti', '500 parça yaratıcı bloklar', 4, 14, 40, 0),
(65, 'Organik Bal', '850gr cam kavanoz', 5, 15, 60, 0),
(66, 'Filtre Kahve 500gr', '%100 Arabica çekirdek', 5, 15, 200, 0),
(67, 'Zeytinyağı 5L', 'Soğuk sıkım sızma teneke', 5, 15, 80, 0),
(68, 'Fındık Kreması', 'Kakaolu 700gr kahvaltılık', 5, 15, 150, 0),
(69, 'Bitki Çayı Seti', 'Karışık kış çayları', 5, 15, 100, 0),
(70, 'Glutensiz Yulaf Ezmesi', 'İnce öğütülmüş 500gr', 5, 15, 90, 0);

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `Varyant`
--

CREATE TABLE `Varyant` (
  `Varyant_ID` int NOT NULL,
  `Renk_Beden` varchar(100) NOT NULL,
  `Fiyat` decimal(10,2) NOT NULL,
  `Stok_Sayisi` int NOT NULL,
  `Urun_ID` int NOT NULL,
  `eski_fiyat` decimal(10,2) DEFAULT NULL,
  `Renk` varchar(20) DEFAULT NULL,
  `Beden` varchar(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Tablo döküm verisi `Varyant`
--

INSERT INTO `Varyant` (`Varyant_ID`, `Renk_Beden`, `Fiyat`, `Stok_Sayisi`, `Urun_ID`, `eski_fiyat`, `Renk`, `Beden`) VALUES
(1, 'Siyah Kordon', 850.00, 30, 2, 1000.00, 'Siyah Kordon', NULL),
(2, 'Gümüş Kordon', 900.00, 20, 2, NULL, 'Gümüş Kordon', NULL),
(3, 'Siyah - Kırmızı', 1200.00, 40, 4, 1111.00, 'Siyah', 'Kırmızı'),
(4, 'Beyaz - Gümüş', 1250.00, 15, 4, NULL, 'Beyaz', 'Gümüş'),
(5, 'Mat Siyah', 450.00, 50, 6, NULL, 'Mat Siyah', NULL),
(6, 'Beyaz', 450.00, 30, 6, NULL, 'Beyaz', NULL),
(7, 'iPhone 14 Pro Uyumlu', 150.00, 100, 11, 245.75, 'Şeffaf', 'Iphone 14 Pro Uyumlu'),
(8, '', 150.00, 80, 11, NULL, 'Samsung S23 Uyumlu', NULL),
(9, 'iPhone 14 Pro', 100.00, 150, 12, NULL, NULL, 'Iphone 14 Pro'),
(10, '', 100.00, 100, 12, 110.00, NULL, 'Samsung S23'),
(11, 'M Beden', 250.00, 80, 13, 475.55, NULL, 'M'),
(12, 'L Beden', 250.00, 70, 13, NULL, NULL, 'L'),
(13, '', 250.00, 50, 13, NULL, NULL, 'XL'),
(14, 'Siyah - M', 450.00, 60, 14, NULL, 'Siyah', 'M'),
(15, 'Gri - L', 450.00, 40, 14, NULL, 'Gri', 'L'),
(16, 'Mavi - 32/32', 600.00, 35, 15, 850.00, 'Mavi', '32/32'),
(17, 'Siyah - 34/32', 600.00, 25, 15, NULL, 'Siyah', '34/32'),
(18, 'Siyah - L Beden', 3500.00, 10, 16, 3670.00, 'Siyah', 'L Beden'),
(19, 'Beyaz - M Beden', 300.00, 40, 17, NULL, 'Beyaz', 'M '),
(20, 'Haki - L Beden', 300.00, 30, 17, NULL, 'Haki', 'L '),
(21, 'Siyah - 42 Numara', 1800.00, 20, 18, 1999.00, 'Siyah', '42 Numara'),
(22, 'Beyaz - 43 Numara', 1800.00, 15, 18, NULL, 'Beyaz', '43 '),
(23, 'Kahverengi - 42 Numara', 2200.00, 10, 19, 2500.00, 'Kahverengi', '42 Numara'),
(24, 'Siyah Süet - 38', 1500.00, 12, 20, NULL, 'Siyah Süet', '38'),
(25, 'Bej - 37', 1500.00, 8, 20, NULL, 'Bej', '37'),
(26, 'Siyah Deri', 750.00, 25, 21, 800.00, NULL, NULL),
(27, 'Taba Rengi', 750.00, 20, 21, NULL, 'Taba', NULL),
(28, 'Koyu Gri', 600.00, 40, 22, NULL, 'Koyu Gri', NULL),
(29, 'Kızıl Tonları', 250.00, 50, 25, NULL, 'Kızıl Tonları', NULL),
(30, 'Nude Tonları', 250.00, 60, 25, 489.00, 'Nude Tonları', NULL),
(31, 'Bordo Kapak', 120.00, 100, 33, NULL, 'Bordo Kapak', NULL),
(32, 'Lacivert Kapak', 120.00, 80, 33, NULL, 'Lacivert Kapak', NULL),
(33, 'Doğal Ahşap', 3500.00, 10, 38, NULL, 'Doğal Ahşap', NULL),
(34, 'Siyah', 3500.00, 5, 38, NULL, 'Siyah', NULL),
(35, '', 8500.00, 8, 39, NULL, 'Sunburst', NULL),
(36, 'Siyah Mat', 8500.00, 6, 39, NULL, 'Mat Siyah', NULL),
(37, 'Pastel Renkler', 400.00, 30, 44, NULL, 'Pastel Renkler', NULL),
(38, 'Gümüş 500ml', 650.00, 40, 45, NULL, 'Gümüş', '500 ml'),
(39, 'Mat Siyah 750ml', 800.00, 25, 45, NULL, 'Mat Siyah', '750 ml'),
(40, 'Beyaz / Gri', 1100.00, 15, 47, NULL, 'Beyaz/Gri', NULL),
(41, 'Siyah Fileli', 2800.00, 10, 49, NULL, 'Siyah Fileli', NULL),
(42, 'Mor 10mm', 300.00, 50, 53, NULL, 'Mor', '10 mm'),
(43, 'Mavi 10mm', 300.00, 40, 53, NULL, 'Mavi ', '10 mm'),
(44, 'Pembe 65cm', 250.00, 30, 54, 567.00, 'Pembe', '65 cm'),
(45, '', 350.00, 100, 55, NULL, 'Yeşil', NULL),
(46, 'Mavi', 350.00, 80, 55, 355.00, 'Mavi', NULL),
(47, 'Mat Siyah - L Beden', 4500.00, 15, 59, 4000.00, 'Mat Siyah', 'L '),
(48, 'Parlak Beyaz - M Beden', 4500.00, 10, 59, NULL, 'Parlak Beyaz', 'M '),
(49, 'Standart Boy', 400.00, 50, 60, NULL, NULL, 'Standart Boy');

-- --------------------------------------------------------

--
-- Görünüm yapısı durumu `view_iade_frekans`
-- (Asıl görünüm için aşağıya bakın)
--
CREATE TABLE `view_iade_frekans` (
`Urun_Adi` varchar(255)
,`Kategori_Adi` varchar(200)
,`Yillik_Iade` int
,`Aylik_Iade` int
,`Haftalik_Iade` int
,`Toplam_Iade_Sayisi` bigint
,`Toplam_Iade_Adeti` decimal(32,0)
);

-- --------------------------------------------------------

--
-- Görünüm yapısı durumu `view_kategori_satis`
-- (Asıl görünüm için aşağıya bakın)
--
CREATE TABLE `view_kategori_satis` (
`Kategori_Adi` varchar(200)
,`Yillik_Satis` int
,`Aylik_Satis` int
,`Haftalik_Satis` int
,`Toplam_Siparis_Sayisi` bigint
,`Toplam_Satilan_Urun_Sayisi` decimal(32,0)
,`Toplam_Getirdigi_Para` decimal(42,2)
,`Sitenin_Komisyon_Kazanci` decimal(51,8)
);

-- --------------------------------------------------------

--
-- Görünüm yapısı durumu `view_satici_gelir`
-- (Asıl görünüm için aşağıya bakın)
--
CREATE TABLE `view_satici_gelir` (
`Satici_ID` int
,`Magaza_Adi` varchar(200)
,`Yillik_Satis` int
,`Aylik_Satis` int
,`Haftalik_Satis` int
,`Toplam_Satis_Miktari` decimal(32,0)
,`Toplam_Ciro` decimal(42,2)
,`Satici_Net_Kazanc` decimal(52,8)
);

-- --------------------------------------------------------

--
-- Görünüm yapısı durumu `view_satici_performans`
-- (Asıl görünüm için aşağıya bakın)
--
CREATE TABLE `view_satici_performans` (
`Satici_ID` int
,`Magaza_Adi` varchar(200)
,`Toplam_Yorum_Sayisi` bigint
,`Puan_Ortalama` decimal(13,2)
);

--
-- Dökümü yapılmış tablolar için indeksler
--

--
-- Tablo için indeksler `Adres`
--
ALTER TABLE `Adres`
  ADD PRIMARY KEY (`Adres_ID`),
  ADD KEY `Musteri_ID` (`Musteri_ID`);

--
-- Tablo için indeksler `Degerlendirme`
--
ALTER TABLE `Degerlendirme`
  ADD PRIMARY KEY (`Degerlendirme_ID`),
  ADD KEY `Siparis_Detay_ID` (`Siparis_Detay_ID`);

--
-- Tablo için indeksler `Favoriler`
--
ALTER TABLE `Favoriler`
  ADD PRIMARY KEY (`Favori_ID`),
  ADD UNIQUE KEY `Musteri_ID` (`Musteri_ID`,`Urun_ID`),
  ADD KEY `Urun_ID` (`Urun_ID`),
  ADD KEY `fk_favoriler_varyant` (`Varyant_ID`);

--
-- Tablo için indeksler `Foto_Degerlendirme`
--
ALTER TABLE `Foto_Degerlendirme`
  ADD PRIMARY KEY (`Foto_ID`),
  ADD KEY `Degerlendirme_ID` (`Degerlendirme_ID`);

--
-- Tablo için indeksler `Iade`
--
ALTER TABLE `Iade`
  ADD PRIMARY KEY (`Iade_ID`),
  ADD KEY `Siparis_Detay_ID` (`Siparis_Detay_ID`);

--
-- Tablo için indeksler `Kargo`
--
ALTER TABLE `Kargo`
  ADD PRIMARY KEY (`Kargo_ID`),
  ADD UNIQUE KEY `Takip_No` (`Takip_No`),
  ADD KEY `Siparis_ID` (`Siparis_ID`);

--
-- Tablo için indeksler `Kategori`
--
ALTER TABLE `Kategori`
  ADD PRIMARY KEY (`Kategori_ID`);

--
-- Tablo için indeksler `Kategori_Komisyon`
--
ALTER TABLE `Kategori_Komisyon`
  ADD PRIMARY KEY (`Komisyon_ID`),
  ADD KEY `Kategori_ID` (`Kategori_ID`);

--
-- Tablo için indeksler `Musteri`
--
ALTER TABLE `Musteri`
  ADD PRIMARY KEY (`Musteri_ID`),
  ADD UNIQUE KEY `Email` (`Email`);

--
-- Tablo için indeksler `Odeme`
--
ALTER TABLE `Odeme`
  ADD PRIMARY KEY (`Odeme_ID`),
  ADD KEY `Siparis_ID` (`Siparis_ID`),
  ADD KEY `fk_odeme_tipi` (`Odeme_Tipi_ID`);

--
-- Tablo için indeksler `Odeme_Tipi`
--
ALTER TABLE `Odeme_Tipi`
  ADD PRIMARY KEY (`Odeme_Tipi_ID`),
  ADD UNIQUE KEY `Odeme_Tipi_Adi` (`Odeme_Tipi_Adi`);

--
-- Tablo için indeksler `Satici`
--
ALTER TABLE `Satici`
  ADD PRIMARY KEY (`Satici_ID`);

--
-- Tablo için indeksler `Sepet`
--
ALTER TABLE `Sepet`
  ADD PRIMARY KEY (`Sepet_ID`),
  ADD KEY `Musteri_ID` (`Musteri_ID`);

--
-- Tablo için indeksler `Sepet_Detay`
--
ALTER TABLE `Sepet_Detay`
  ADD PRIMARY KEY (`Sepet_Detay_ID`),
  ADD KEY `Varyant_ID` (`Varyant_ID`),
  ADD KEY `Sepet_ID` (`Sepet_ID`),
  ADD KEY `fk_sepet_urun` (`Urun_ID`);

--
-- Tablo için indeksler `Siparis`
--
ALTER TABLE `Siparis`
  ADD PRIMARY KEY (`Siparis_ID`),
  ADD KEY `Musteri_ID` (`Musteri_ID`),
  ADD KEY `Adres_ID` (`Adres_ID`);

--
-- Tablo için indeksler `Siparis_Detay`
--
ALTER TABLE `Siparis_Detay`
  ADD PRIMARY KEY (`Siparis_Detay_ID`),
  ADD KEY `Siparis_ID` (`Siparis_ID`),
  ADD KEY `Varyant_ID` (`Varyant_ID`),
  ADD KEY `fk_sd_urun` (`Urun_ID`);

--
-- Tablo için indeksler `Siparis_Durum`
--
ALTER TABLE `Siparis_Durum`
  ADD PRIMARY KEY (`Siparis_Durum_ID`),
  ADD KEY `Siparis_ID` (`Siparis_ID`);

--
-- Tablo için indeksler `Urun`
--
ALTER TABLE `Urun`
  ADD PRIMARY KEY (`Urun_ID`),
  ADD KEY `Satici_ID` (`Satici_ID`),
  ADD KEY `Kategori_ID` (`Kategori_ID`);

--
-- Tablo için indeksler `Varyant`
--
ALTER TABLE `Varyant`
  ADD PRIMARY KEY (`Varyant_ID`),
  ADD KEY `Urun_ID` (`Urun_ID`);

--
-- Dökümü yapılmış tablolar için AUTO_INCREMENT değeri
--

--
-- Tablo için AUTO_INCREMENT değeri `Adres`
--
ALTER TABLE `Adres`
  MODIFY `Adres_ID` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=51;

--
-- Tablo için AUTO_INCREMENT değeri `Degerlendirme`
--
ALTER TABLE `Degerlendirme`
  MODIFY `Degerlendirme_ID` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- Tablo için AUTO_INCREMENT değeri `Favoriler`
--
ALTER TABLE `Favoriler`
  MODIFY `Favori_ID` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- Tablo için AUTO_INCREMENT değeri `Foto_Degerlendirme`
--
ALTER TABLE `Foto_Degerlendirme`
  MODIFY `Foto_ID` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- Tablo için AUTO_INCREMENT değeri `Iade`
--
ALTER TABLE `Iade`
  MODIFY `Iade_ID` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- Tablo için AUTO_INCREMENT değeri `Kargo`
--
ALTER TABLE `Kargo`
  MODIFY `Kargo_ID` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- Tablo için AUTO_INCREMENT değeri `Kategori`
--
ALTER TABLE `Kategori`
  MODIFY `Kategori_ID` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=16;

--
-- Tablo için AUTO_INCREMENT değeri `Kategori_Komisyon`
--
ALTER TABLE `Kategori_Komisyon`
  MODIFY `Komisyon_ID` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=16;

--
-- Tablo için AUTO_INCREMENT değeri `Musteri`
--
ALTER TABLE `Musteri`
  MODIFY `Musteri_ID` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=51;

--
-- Tablo için AUTO_INCREMENT değeri `Odeme`
--
ALTER TABLE `Odeme`
  MODIFY `Odeme_ID` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- Tablo için AUTO_INCREMENT değeri `Odeme_Tipi`
--
ALTER TABLE `Odeme_Tipi`
  MODIFY `Odeme_Tipi_ID` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- Tablo için AUTO_INCREMENT değeri `Satici`
--
ALTER TABLE `Satici`
  MODIFY `Satici_ID` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- Tablo için AUTO_INCREMENT değeri `Sepet`
--
ALTER TABLE `Sepet`
  MODIFY `Sepet_ID` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- Tablo için AUTO_INCREMENT değeri `Sepet_Detay`
--
ALTER TABLE `Sepet_Detay`
  MODIFY `Sepet_Detay_ID` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- Tablo için AUTO_INCREMENT değeri `Siparis`
--
ALTER TABLE `Siparis`
  MODIFY `Siparis_ID` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- Tablo için AUTO_INCREMENT değeri `Siparis_Detay`
--
ALTER TABLE `Siparis_Detay`
  MODIFY `Siparis_Detay_ID` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- Tablo için AUTO_INCREMENT değeri `Siparis_Durum`
--
ALTER TABLE `Siparis_Durum`
  MODIFY `Siparis_Durum_ID` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- Tablo için AUTO_INCREMENT değeri `Urun`
--
ALTER TABLE `Urun`
  MODIFY `Urun_ID` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=71;

--
-- Tablo için AUTO_INCREMENT değeri `Varyant`
--
ALTER TABLE `Varyant`
  MODIFY `Varyant_ID` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=50;

-- --------------------------------------------------------

--
-- Görünüm yapısı `view_iade_frekans`
--
DROP TABLE IF EXISTS `view_iade_frekans`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `view_iade_frekans`  AS SELECT `u`.`Urun_Adi` AS `Urun_Adi`, `k`.`Kategori_Adi` AS `Kategori_Adi`, year(`i`.`Iade_Tarihi`) AS `Yillik_Iade`, month(`i`.`Iade_Tarihi`) AS `Aylik_Iade`, week(`i`.`Iade_Tarihi`,0) AS `Haftalik_Iade`, count(`i`.`Iade_ID`) AS `Toplam_Iade_Sayisi`, sum(`i`.`Iade_adet`) AS `Toplam_Iade_Adeti` FROM (((`iade` `i` join `siparis_detay` `sd` on((`i`.`Siparis_Detay_ID` = `sd`.`Siparis_Detay_ID`))) join `urun` `u` on(((`sd`.`Urun_ID` = `u`.`Urun_ID`) or `sd`.`Varyant_ID` in (select `varyant`.`Varyant_ID` from `varyant` where (`varyant`.`Urun_ID` = `u`.`Urun_ID`))))) join `kategori` `k` on((`u`.`Kategori_ID` = `k`.`Kategori_ID`))) GROUP BY `u`.`Urun_Adi`, `k`.`Kategori_Adi`, `Yillik_Iade`, `Aylik_Iade`, `Haftalik_Iade` ORDER BY `Yillik_Iade` DESC, `Aylik_Iade` DESC, `Haftalik_Iade` DESC, `Toplam_Iade_Sayisi` DESC ;

-- --------------------------------------------------------

--
-- Görünüm yapısı `view_kategori_satis`
--
DROP TABLE IF EXISTS `view_kategori_satis`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `view_kategori_satis`  AS SELECT `k`.`Kategori_Adi` AS `Kategori_Adi`, year(`krg`.`Kargo_Verilme_Tarihi`) AS `Yillik_Satis`, month(`krg`.`Kargo_Verilme_Tarihi`) AS `Aylik_Satis`, week(`krg`.`Kargo_Verilme_Tarihi`,0) AS `Haftalik_Satis`, count(distinct `sd`.`Siparis_ID`) AS `Toplam_Siparis_Sayisi`, sum(`sd`.`Adet`) AS `Toplam_Satilan_Urun_Sayisi`, sum((`sd`.`Adet` * `sd`.`Satin_Alinan_Fiyat`)) AS `Toplam_Getirdigi_Para`, sum(((`sd`.`Adet` * `sd`.`Satin_Alinan_Fiyat`) * (`kk`.`Komisyon_Orani` / 100))) AS `Sitenin_Komisyon_Kazanci` FROM (((((`kategori` `k` join `kategori_komisyon` `kk` on((`k`.`Kategori_ID` = `kk`.`Kategori_ID`))) join `urun` `u` on((`k`.`Kategori_ID` = `u`.`Kategori_ID`))) join `siparis_detay` `sd` on(((`sd`.`Urun_ID` = `u`.`Urun_ID`) or `sd`.`Varyant_ID` in (select `varyant`.`Varyant_ID` from `varyant` where (`varyant`.`Urun_ID` = `u`.`Urun_ID`))))) join `siparis_durum` `durum` on((`sd`.`Siparis_ID` = `durum`.`Siparis_ID`))) join `kargo` `krg` on((`sd`.`Siparis_ID` = `krg`.`Siparis_ID`))) WHERE (`durum`.`Siparis_Durum` = 'Teslim Edildi') GROUP BY `k`.`Kategori_Adi`, `Yillik_Satis`, `Aylik_Satis`, `Haftalik_Satis` ORDER BY `Yillik_Satis` DESC, `Aylik_Satis` DESC, `Haftalik_Satis` DESC ;

-- --------------------------------------------------------

--
-- Görünüm yapısı `view_satici_gelir`
--
DROP TABLE IF EXISTS `view_satici_gelir`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `view_satici_gelir`  AS SELECT `sat`.`Satici_ID` AS `Satici_ID`, `sat`.`Magaza_Adi` AS `Magaza_Adi`, year(`krg`.`Kargo_Verilme_Tarihi`) AS `Yillik_Satis`, month(`krg`.`Kargo_Verilme_Tarihi`) AS `Aylik_Satis`, week(`krg`.`Kargo_Verilme_Tarihi`,0) AS `Haftalik_Satis`, sum(`sd`.`Adet`) AS `Toplam_Satis_Miktari`, sum((`sd`.`Adet` * `sd`.`Satin_Alinan_Fiyat`)) AS `Toplam_Ciro`, (sum((`sd`.`Adet` * `sd`.`Satin_Alinan_Fiyat`)) * (1 - (`kk`.`Komisyon_Orani` / 100))) AS `Satici_Net_Kazanc` FROM (((((((`satici` `sat` join `urun` `u` on((`sat`.`Satici_ID` = `u`.`Satici_ID`))) join `siparis_detay` `sd` on(((`sd`.`Urun_ID` = `u`.`Urun_ID`) or `sd`.`Varyant_ID` in (select `varyant`.`Varyant_ID` from `varyant` where (`varyant`.`Urun_ID` = `u`.`Urun_ID`))))) join `kategori` `k` on((`u`.`Kategori_ID` = `k`.`Kategori_ID`))) join `kategori_komisyon` `kk` on((`kk`.`Kategori_ID` = `k`.`Kategori_ID`))) join `siparis` `s` on((`sd`.`Siparis_ID` = `s`.`Siparis_ID`))) join `siparis_durum` `durum` on((`s`.`Siparis_ID` = `durum`.`Siparis_ID`))) join `kargo` `krg` on((`s`.`Siparis_ID` = `krg`.`Siparis_ID`))) WHERE (`durum`.`Siparis_Durum` = 'Teslim Edildi') GROUP BY `sat`.`Satici_ID`, `sat`.`Magaza_Adi`, `Yillik_Satis`, `Aylik_Satis`, `Haftalik_Satis` ORDER BY `Yillik_Satis` DESC, `Aylik_Satis` DESC, `Haftalik_Satis` DESC ;

-- --------------------------------------------------------

--
-- Görünüm yapısı `view_satici_performans`
--
DROP TABLE IF EXISTS `view_satici_performans`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `view_satici_performans`  AS SELECT `sat`.`Satici_ID` AS `Satici_ID`, `sat`.`Magaza_Adi` AS `Magaza_Adi`, count(`d`.`Degerlendirme_ID`) AS `Toplam_Yorum_Sayisi`, ifnull(round(avg(`d`.`Puan`),2),0) AS `Puan_Ortalama` FROM (((`satici` `sat` join `urun` `u` on((`sat`.`Satici_ID` = `u`.`Satici_ID`))) join `siparis_detay` `sd` on(((`sd`.`Urun_ID` = `u`.`Urun_ID`) or `sd`.`Varyant_ID` in (select `varyant`.`Varyant_ID` from `varyant` where (`varyant`.`Urun_ID` = `u`.`Urun_ID`))))) join `degerlendirme` `d` on((`sd`.`Siparis_Detay_ID` = `d`.`Siparis_Detay_ID`))) GROUP BY `sat`.`Satici_ID`, `sat`.`Magaza_Adi` ;

--
-- Dökümü yapılmış tablolar için kısıtlamalar
--

--
-- Tablo kısıtlamaları `Adres`
--
ALTER TABLE `Adres`
  ADD CONSTRAINT `adres_ibfk_1` FOREIGN KEY (`Musteri_ID`) REFERENCES `Musteri` (`Musteri_ID`) ON DELETE CASCADE;

--
-- Tablo kısıtlamaları `Degerlendirme`
--
ALTER TABLE `Degerlendirme`
  ADD CONSTRAINT `degerlendirme_ibfk_1` FOREIGN KEY (`Siparis_Detay_ID`) REFERENCES `Siparis_Detay` (`Siparis_Detay_ID`) ON DELETE CASCADE;

--
-- Tablo kısıtlamaları `Favoriler`
--
ALTER TABLE `Favoriler`
  ADD CONSTRAINT `favoriler_ibfk_1` FOREIGN KEY (`Musteri_ID`) REFERENCES `Musteri` (`Musteri_ID`) ON DELETE CASCADE,
  ADD CONSTRAINT `favoriler_ibfk_2` FOREIGN KEY (`Urun_ID`) REFERENCES `Urun` (`Urun_ID`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_favoriler_varyant` FOREIGN KEY (`Varyant_ID`) REFERENCES `Varyant` (`Varyant_ID`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Tablo kısıtlamaları `Foto_Degerlendirme`
--
ALTER TABLE `Foto_Degerlendirme`
  ADD CONSTRAINT `foto_degerlendirme_ibfk_1` FOREIGN KEY (`Degerlendirme_ID`) REFERENCES `Degerlendirme` (`Degerlendirme_ID`) ON DELETE CASCADE;

--
-- Tablo kısıtlamaları `Iade`
--
ALTER TABLE `Iade`
  ADD CONSTRAINT `iade_ibfk_1` FOREIGN KEY (`Siparis_Detay_ID`) REFERENCES `Siparis_Detay` (`Siparis_Detay_ID`) ON DELETE CASCADE;

--
-- Tablo kısıtlamaları `Kargo`
--
ALTER TABLE `Kargo`
  ADD CONSTRAINT `kargo_ibfk_1` FOREIGN KEY (`Siparis_ID`) REFERENCES `Siparis` (`Siparis_ID`) ON DELETE CASCADE;

--
-- Tablo kısıtlamaları `Kategori_Komisyon`
--
ALTER TABLE `Kategori_Komisyon`
  ADD CONSTRAINT `kategori_komisyon_ibfk_1` FOREIGN KEY (`Kategori_ID`) REFERENCES `Kategori` (`Kategori_ID`) ON DELETE CASCADE;

--
-- Tablo kısıtlamaları `Odeme`
--
ALTER TABLE `Odeme`
  ADD CONSTRAINT `fk_odeme_tipi` FOREIGN KEY (`Odeme_Tipi_ID`) REFERENCES `Odeme_Tipi` (`Odeme_Tipi_ID`),
  ADD CONSTRAINT `odeme_ibfk_1` FOREIGN KEY (`Siparis_ID`) REFERENCES `Siparis` (`Siparis_ID`) ON DELETE CASCADE;

--
-- Tablo kısıtlamaları `Sepet`
--
ALTER TABLE `Sepet`
  ADD CONSTRAINT `sepet_ibfk_1` FOREIGN KEY (`Musteri_ID`) REFERENCES `Musteri` (`Musteri_ID`) ON DELETE CASCADE;

--
-- Tablo kısıtlamaları `Sepet_Detay`
--
ALTER TABLE `Sepet_Detay`
  ADD CONSTRAINT `fk_sepet_urun` FOREIGN KEY (`Urun_ID`) REFERENCES `Urun` (`Urun_ID`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_sepet_varyant` FOREIGN KEY (`Varyant_ID`) REFERENCES `Varyant` (`Varyant_ID`) ON DELETE SET NULL,
  ADD CONSTRAINT `sepet_detay_ibfk_2` FOREIGN KEY (`Sepet_ID`) REFERENCES `Sepet` (`Sepet_ID`) ON DELETE CASCADE;

--
-- Tablo kısıtlamaları `Siparis`
--
ALTER TABLE `Siparis`
  ADD CONSTRAINT `siparis_ibfk_1` FOREIGN KEY (`Musteri_ID`) REFERENCES `Musteri` (`Musteri_ID`) ON DELETE CASCADE,
  ADD CONSTRAINT `siparis_ibfk_2` FOREIGN KEY (`Adres_ID`) REFERENCES `Adres` (`Adres_ID`) ON DELETE CASCADE;

--
-- Tablo kısıtlamaları `Siparis_Detay`
--
ALTER TABLE `Siparis_Detay`
  ADD CONSTRAINT `fk_sd_urun` FOREIGN KEY (`Urun_ID`) REFERENCES `Urun` (`Urun_ID`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_sd_varyant` FOREIGN KEY (`Varyant_ID`) REFERENCES `Varyant` (`Varyant_ID`) ON DELETE SET NULL,
  ADD CONSTRAINT `siparis_detay_ibfk_1` FOREIGN KEY (`Siparis_ID`) REFERENCES `Siparis` (`Siparis_ID`) ON DELETE CASCADE;

--
-- Tablo kısıtlamaları `Siparis_Durum`
--
ALTER TABLE `Siparis_Durum`
  ADD CONSTRAINT `siparis_durum_ibfk_1` FOREIGN KEY (`Siparis_ID`) REFERENCES `Siparis` (`Siparis_ID`) ON DELETE CASCADE;

--
-- Tablo kısıtlamaları `Urun`
--
ALTER TABLE `Urun`
  ADD CONSTRAINT `urun_ibfk_1` FOREIGN KEY (`Satici_ID`) REFERENCES `Satici` (`Satici_ID`) ON DELETE CASCADE,
  ADD CONSTRAINT `urun_ibfk_2` FOREIGN KEY (`Kategori_ID`) REFERENCES `Kategori` (`Kategori_ID`) ON DELETE CASCADE;

--
-- Tablo kısıtlamaları `Varyant`
--
ALTER TABLE `Varyant`
  ADD CONSTRAINT `varyant_ibfk_1` FOREIGN KEY (`Urun_ID`) REFERENCES `Urun` (`Urun_ID`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
