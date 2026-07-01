# Transcript to Vocab Skill - Main Script
# Podcast JSON transcript dosyalarını İngilizce vocabulary learning materyaline dönüştürür

param(
    [string]$inputFolder = "cleaned_transcripts",
    [string]$jsonFile = ""
)

# Eğer jsonFile belirtilmişse o dosyayı işle
if ($jsonFile) {
    $jsonFiles = @(Get-ChildItem -Path $inputFolder -Filter $jsonFile -File)
} else {
    $jsonFiles = Get-ChildItem -Path $inputFolder -Filter "*.json" -File | Sort-Object Name
}

if ($jsonFiles.Count -eq 0) {
    Write-Host "⚠ Uyarı: $inputFolder klasöründe JSON dosyası bulunamadı"
    exit 1
}

$processedCount = 0

foreach ($file in $jsonFiles) {
    try {
        $jsonContent = Get-Content -Path $file.FullName -Raw | ConvertFrom-Json
        $keywords = $jsonContent.keywords
        $fullText = $jsonContent.fullText

        # Keywords map'ini oluştur
        $keywordMap = @{}
        foreach ($kw in $keywords) {
            $keywordMap[$kw.name] = $kw
        }

        # Cümlelere böl
        $sentences = $fullText -split '(?<=[.!?])\s+' | Where-Object { $_.Length -gt 0 }

        # Output
        $outputPath = Join-Path $inputFolder "$($file.BaseName).txt"
        $outputContent = @()
        $addedToOutput = @()

        foreach ($keyword in $keywords) {
            $name = $keyword.name
            $definition = $keyword.definition

            # Skip if already added to output
            if ($addedToOutput -contains $name) {
                continue
            }

            # Definition'ı parse et - 3 format olabilir
            $partOfSpeech = ""
            $definitionText = ""
            $exampleInDef = ""

            # Format 3: "alt_form - (idiom) def "example""
            if ($definition -match '^.+?\s+-\s+\(([^)]+)\)\s+(.+?)\s+"(.+)"$') {
                $partOfSpeech = $matches[1]
                $definitionText = $matches[2]
                $exampleInDef = $matches[3]
            }
            # Format 2: "(p1) text - (p2) def "example""
            elseif ($definition -match '^\(([^)]+)\)\s+.+?\s-\s+\(([^)]+)\)\s+(.+?)\s+"(.+)"$') {
                $partOfSpeech = $matches[2]
                $definitionText = $matches[3]
                $exampleInDef = $matches[4]
            }
            # Format 1: "(part_of_speech) def_text "example""
            elseif ($definition -match '^\(([^)]+)\)\s+(.+?)\s+"(.+)"$') {
                $partOfSpeech = $matches[1]
                $definitionText = $matches[2]
                $exampleInDef = $matches[3]
            }

            # Header
            if ($partOfSpeech -eq "idiom") {
                $outputContent += "$($name) (idiom): $($definitionText)"
            } else {
                $outputContent += "$($name): $($definitionText)"
            }

            $addedToOutput += $name
            $outputContent += " - $($exampleInDef)"

            # fullText'ten anlamlı örnek bul
            $relatedKeywords = @()

            for ($i = 0; $i -lt $sentences.Count; $i++) {
                $sentence = $sentences[$i]

                if ($sentence -imatch [regex]::Escape($name)) {
                    $cleanedSentence = $sentence.Trim()

                    # Tanım amaçlı cümleler - improved filter
                    $isDefinitional = $cleanedSentence -imatch "^(This|The|It|And)\s+(phrase|word|term|idiom|expression)" -or `
                                      $cleanedSentence -imatch "^It\s+is|^It\s+stands|^It\s+means|^That\s+means|which\s+means"

                    if (-not $isDefinitional) {
                        $outputContent += " - $($cleanedSentence)"

                        # Context window: bulunduğu cümle + önceki 1 + sonraki 1 cümle
                        $contextStart = [Math]::Max(0, $i - 1)
                        $contextEnd = [Math]::Min($sentences.Count - 1, $i + 1)

                        $contextWindow = ""
                        for ($j = $contextStart; $j -le $contextEnd; $j++) {
                            $contextWindow += $sentences[$j] + " "
                        }

                        # Context'te başka keywords var mı kontrol et
                        foreach ($otherKw in $keywords) {
                            $otherName = $otherKw.name
                            if ($otherName -ne $name -and $contextWindow -imatch [regex]::Escape($otherName) -and `
                                $relatedKeywords -notcontains $otherName -and $addedToOutput -notcontains $otherName) {
                                $relatedKeywords += $otherName
                            }
                        }

                        break
                    }
                }
            }

            # Related keywords'leri ekle
            foreach ($relatedName in $relatedKeywords) {
                $outputContent += ""

                $relatedKw = $keywordMap[$relatedName]
                $relDefinition = $relatedKw.definition

                $relPartOfSpeech = ""
                $relDefinitionText = ""
                $relExampleInDef = ""

                # Definition'ı parse et
                if ($relDefinition -match '^.+?\s+-\s+\(([^)]+)\)\s+(.+?)\s+"(.+)"$') {
                    $relPartOfSpeech = $matches[1]
                    $relDefinitionText = $matches[2]
                    $relExampleInDef = $matches[3]
                } elseif ($relDefinition -match '^\(([^)]+)\)\s+.+?\s-\s+\(([^)]+)\)\s+(.+?)\s+"(.+)"$') {
                    $relPartOfSpeech = $matches[2]
                    $relDefinitionText = $matches[3]
                    $relExampleInDef = $matches[4]
                } elseif ($relDefinition -match '^\(([^)]+)\)\s+(.+?)\s+"(.+)"$') {
                    $relPartOfSpeech = $matches[1]
                    $relDefinitionText = $matches[2]
                    $relExampleInDef = $matches[3]
                }

                if ($relPartOfSpeech -eq "idiom") {
                    $outputContent += "$($relatedName) (idiom): $($relDefinitionText)"
                } else {
                    $outputContent += "$($relatedName): $($relDefinitionText)"
                }

                $outputContent += " - $($relExampleInDef)"

                # Bu keyword'ün örneğini bul
                for ($i = 0; $i -lt $sentences.Count; $i++) {
                    $sentence = $sentences[$i]

                    if ($sentence -imatch [regex]::Escape($relatedName)) {
                        $cleanedSentence = $sentence.Trim()
                        $isDefinitional = $cleanedSentence -imatch "^(This|The|It|And)\s+(phrase|word|term|idiom|expression)" -or `
                                          $cleanedSentence -imatch "^It\s+is|^It\s+stands|^It\s+means|^That\s+means|which\s+means"

                        if (-not $isDefinitional) {
                            $outputContent += " - $($cleanedSentence)"
                            break
                        }
                    }
                }

                $addedToOutput += $relatedName
            }

            $outputContent += ""
        }

        # Dosyaya yaz
        $outputContent | Out-File -FilePath $outputPath -Encoding UTF8 -Force

        $processedCount++
        Write-Host "✓ $($file.Name) → $([System.IO.Path]::GetFileName($outputPath))"

    } catch {
        Write-Host "✗ Hata ($($file.Name)): $_"
    }
}

Write-Host "`n✓ Toplam $processedCount dosya başarıyla işlendi"
