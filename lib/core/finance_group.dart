//import 'package:flutter/material.dart';

/// Gelir ve Gider türlerini ayırmak için enum
enum CategoryType { gelir, gider }

/// Ana kategori modeli
class Category {
  final int id; // örn: 201
  final String name; // örn: 'Market'
  final CategoryType type; // gelir/gider
  final List<SubCategory> subcategories;

  const Category({
    required this.id,
    required this.name,
    required this.type,
    required this.subcategories,
  });
}

/// Alt kategori modeli
class SubCategory {
  final int subId; // örn: 20101
  final String name; // örn: 'Gıda'

  const SubCategory({required this.subId, required this.name});
}

/// Tüm kategori listesi
const List<Category> categoryList = [
  // GELİR KATEGORİLERİ
  Category(
    id: 101,
    name: 'Ana Gelir',
    type: CategoryType.gelir,
    subcategories: [
      SubCategory(subId: 10101, name: 'Maaş'),
      SubCategory(subId: 10102, name: 'Serbest Çalışma'),
      SubCategory(subId: 10103, name: 'Diğer Gelir'),
    ],
  ),
  Category(
    id: 102,
    name: 'Ek Gelir',
    type: CategoryType.gelir,
    subcategories: [
      SubCategory(subId: 10201, name: 'Ek-Gelir'),
      SubCategory(subId: 10202, name: 'Yatırım Geliri'),
      SubCategory(subId: 10203, name: 'Faiz / Temettü'),
    ],
  ),
  Category(
    id: 103,
    name: 'Transfer / Diğer',
    type: CategoryType.gelir,
    subcategories: [
      SubCategory(subId: 10301, name: 'Kredi'),
      SubCategory(subId: 10302, name: 'Geri Ödeme'),
      SubCategory(subId: 10303, name: 'Diğer Transfer'),
    ],
  ),

  // GİDER KATEGORİLERİ
  Category(
    id: 200,
    name: 'Araç',
    type: CategoryType.gider,
    subcategories: [
      SubCategory(subId: 20001, name: 'Sigorta'),
      SubCategory(subId: 20002, name: 'Kasko'),
      SubCategory(subId: 20003, name: 'Tamir/Bakım'),
      SubCategory(subId: 20004, name: 'Muayene'),
      SubCategory(subId: 20005, name: 'Yedek Parça/Sarf Malzemeleri'),
    ],
  ),
  Category(
    id: 201,
    name: 'Market',
    type: CategoryType.gider,
    subcategories: [
      SubCategory(subId: 20101, name: 'Gıda'),
      SubCategory(subId: 20102, name: 'Temizlik'),
      SubCategory(subId: 20103, name: 'Kozmetik'),
      SubCategory(subId: 20104, name: 'Sağlık'),
      SubCategory(subId: 20105, name: 'Bebek Ürünleri'),
    ],
  ),
  Category(
    id: 202,
    name: 'Yeme-İçme',
    type: CategoryType.gider,
    subcategories: [
      SubCategory(subId: 20201, name: 'Kahve'),
      SubCategory(subId: 20202, name: 'Restoran'),
      SubCategory(subId: 20203, name: 'Fast-food'),
      SubCategory(subId: 20204, name: 'Tatlı'),
    ],
  ),
  Category(
    id: 203,
    name: 'Kişisel Bakım',
    type: CategoryType.gider,
    subcategories: [
      SubCategory(subId: 20301, name: 'Deodorant'),
      SubCategory(subId: 20302, name: 'Cilt Bakım'),
      SubCategory(subId: 20303, name: 'Parfüm'),
      SubCategory(subId: 20304, name: 'Traş Ürünleri'),
    ],
  ),
  Category(
    id: 204,
    name: 'Sağlık',
    type: CategoryType.gider,
    subcategories: [
      SubCategory(subId: 20401, name: 'Eczane'),
      SubCategory(subId: 20402, name: 'Takviye Gıda'),
      SubCategory(subId: 20403, name: 'İlaç'),
      SubCategory(subId: 20404, name: 'Sağlık Ürünleri'),
    ],
  ),
  Category(
    id: 205,
    name: 'Giyim',
    type: CategoryType.gider,
    subcategories: [
      SubCategory(subId: 20501, name: 'Gömlek'),
      SubCategory(subId: 20502, name: 'Pantolon'),
      SubCategory(subId: 20503, name: 'Ayakkabı'),
      SubCategory(subId: 20504, name: 'İç Giyim'),
    ],
  ),
  Category(
    id: 206,
    name: 'Ev & Yaşam',
    type: CategoryType.gider,
    subcategories: [
      SubCategory(subId: 20601, name: 'Mobilya'),
      SubCategory(subId: 20602, name: 'Dekorasyon'),
      SubCategory(subId: 20603, name: 'Elektrik'),
      SubCategory(subId: 20604, name: 'Temizlik Ürünü'),
    ],
  ),
  Category(
    id: 207,
    name: 'Ulaşım',
    type: CategoryType.gider,
    subcategories: [
      SubCategory(subId: 20701, name: 'Toplu Taşıma'),
      SubCategory(subId: 20702, name: 'Yakıt'),
      SubCategory(subId: 20703, name: 'Taksi'),
      SubCategory(subId: 20704, name: 'Araç Kiralama'),
    ],
  ),
  Category(
    id: 208,
    name: 'Eğitim',
    type: CategoryType.gider,
    subcategories: [
      SubCategory(subId: 20801, name: 'Kitap'),
      SubCategory(subId: 20802, name: 'Kurs'),
      SubCategory(subId: 20803, name: 'Yazılım'),
      SubCategory(subId: 20804, name: 'Eğitim Materyali'),
    ],
  ),
  Category(
    id: 209,
    name: 'Eğlence',
    type: CategoryType.gider,
    subcategories: [
      SubCategory(subId: 20901, name: 'Tiyatro'),
      SubCategory(subId: 20902, name: 'Film'),
      SubCategory(subId: 20903, name: 'Müzik'),
    ],
  ),
  Category(
    id: 210,
    name: 'Fatura',
    type: CategoryType.gider,
    subcategories: [
      SubCategory(subId: 21001, name: 'Elektrik'),
      SubCategory(subId: 21002, name: 'Su'),
      SubCategory(subId: 21003, name: 'Doğalgaz'),
      SubCategory(subId: 21004, name: 'İnternet'),
      SubCategory(subId: 21005, name: 'Gsm'),
      SubCategory(subId: 21006, name: 'Dijital Abonelik'),
    ],
  ),
  Category(
    id: 211,
    name: 'Diğer',
    type: CategoryType.gider,
    subcategories: [
      SubCategory(subId: 21101, name: 'Bağış'),
      SubCategory(subId: 21102, name: 'Hediye'),
      SubCategory(subId: 21103, name: 'Tanımsız Harcamalar'),
    ],
  ),
];
