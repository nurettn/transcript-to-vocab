# Transcript to Vocab Skill

Podcast transcript JSON dosyalarını English vocabulary learning materyaline dönüştürür.

## Özellikleri

- 📄 JSON transcript dosyalarından keywords'leri çıkartır
- 🎓 Her keyword için tanım, definition'daki örnek cümle ve fullText'ten alınan ek örnek cümleler ekler
- 🔍 fullText'ten anlamlı bağlamda (tanım amaçlı değil) kullanılan cümleleri bulur
- 🔗 Context window'da geçen ilişkili keywords'leri otomatik olarak tespit eder ve ekler
- ⚡ Geliştirilmiş tanım filtresi ile tanım amaçlı cümleler hariç tutar
- 📚 B2-C1 seviyesi English öğrenenleri için uygun materyal oluşturur
- 🏷️ Idiom'ları otomatik olarak etiketler

## Kullanım

### Tüm JSON dosyalarını işle
```powershell
/transcript-to-vocab
```

### Belirli bir JSON dosyasını işle
```powershell
/transcript-to-vocab --jsonFile 2494.json
```

### Özel klasörden işle
```powershell
/transcript-to-vocab --inputFolder ./my-transcripts
```

## Çıktı Formatı

Her JSON dosyası için aynı isimde bir TXT dosyası oluşturulur:

```
keyword (idiom): tanım
 - Definition'daki örnek cümle
 - fullText'ten alınan anlamlı cümle

keyword: tanım
 - Definition'daki örnek cümle
 - fullText'ten alınan anlamlı cümle
```

## Örnek

**Input:** 2494.json
```json
{
  "keywords": [
    {
      "name": "rash",
      "definition": "(adjective) impulsive \"Dropping out of the course was a rash decision he quickly regretted.\""
    }
  ],
  "fullText": "Have you ever made a rash decision..."
}
```

**Output:** 2494.txt
```
rash: impulsive
 - Dropping out of the course was a rash decision he quickly regretted.
 - Have you ever made a rash decision that you didn't think through?
```

## Gereksinimler

- PowerShell 5.1+
- JSON dosyalarının `.json` uzantısı olması
- JSON dosyalarının `keywords` ve `fullText` alanlarını içermesi
