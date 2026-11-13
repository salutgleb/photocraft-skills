# Команды LightCraft для отбора и проявки съёмки

Сверено с исходным кодом LightCraft 0.21.1, ни одна команда не запускалась. Перед работой проверь нужную команду в установленной версии: `lightcraft-cli commands | grep -A1 <имя>`.

Параметры записаны так, как они стоят в файле шагов. Знак `?` значит, что параметр можно не писать. Если команда работает с выделенными кадрами, `ids` задаёт кадры явно.

## Каталог и выделение

| Команда | Параметры | Что делает |
|---|---|---|
| `library.import` | `{"paths": ["полный путь к папке или файлу"], "mode": "add"}` | Добавляет файлы, папки читает вместе с вложенными. Отвечает `imported` (новые id), `duplicates`, `failed`. Выделяет только первый добавленный кадр |
| `library.source` | `{"kind": "all"}` | Показывает все кадры каталога |
| `library.clearFilter` | `{}` | Снимает фильтр показа |
| `library.selectAll` | `{}` | Выделяет все показанные кадры |
| `library.select` | `{"ids": [12, 13], "active": 12, "mode"?: "replace"}` | Выделяет кадры. `active` делает кадр активным, без него активен первый |
| `library.selectBy` | `{"flag"?: "pick", "rating"?: 3, "ratingOp"?: "gte", "label"?: "yellow", "add"?: false}` | Выделяет среди показанных кадров. `ratingOp` бывает `gte`, `eq`, `lte` |
| `catalog.query` | `{"filter"?: {…}, "sort"?: {…}, "offset"?: 0, "limit"?: 200}` | Список кадров: `id`, `fileName`, `format`, `rating`, `flag`, `label`, `previewOnly`. Без `filter` показывает текущий вид |
| `photo.inspect` | `{"id": 12}` | Всё о кадре. Полный путь в `source.path`, оценки отбора в `analysis` |
| `develop.get` | `{"id": 12}` | Настройки проявки кадра |
| `library.xmpPreferences` | `{}` | Показывает `autoWrite` и `naming` для файлов `.xmp` |

Поля фильтра `catalog.query`: `rating` вместе с `ratingOp` (`atLeast`, `exactly`, `atMost`), `flag` (`pick`, `reject`, `none`), `flags` (список), `label`, `labels`, `keyword`, `camera`, `lens`, `date`, `dateFrom`, `dateTo`, `text`. Поля `minRating` нет.

## Отбор

| Команда | Параметры | Что делает |
|---|---|---|
| `photo.analyze` | `{"ids"?, "rejectBelow"?: 0..100, "pickBest"?: false, "burstGap"?: 10, "similarity"?: 0.93}` | Считает резкость и пересветы, собирает похожие кадры, снятые с разницей не больше `burstGap` секунд, в группы. Отвечает `photos: [{id, sharpness, clipped, group, best}]`, `groups`, `rejected`, `picked`, `failed`. Без `rejectBelow` и `pickBest` флажки не ставит. Без `ids` берёт выделенные кадры, а если выделен один, то все показанные |
| `library.findSimilar` | `{"id"?, "similarity"?: 0.8, "filter"?: true}` | Кадры, похожие на активный, по убыванию сходства |
| `photo.flag` | `{"flag": "pick", "ids": […]}` | Флажок `pick`, `reject` или `none` |
| `photo.rate` | `{"rating": 0..5, "ids": […]}` | Оценка звёздами |
| `photo.label` | `{"label": "yellow", "ids": […]}` | Цветная метка `red`, `yellow`, `green`, `blue`, `purple` или `none` |
| `photo.saveMetadataToFile` | `{"ids": […]}` | Пишет `.xmp` рядом с исходником. Только с согласия человека |
| `export.contactSheet` | `{"path": "…/лист.pdf", "ids"?, "paper"?: "a4", "landscape"?: false, "columns"?: 3, "rows"?: 4, "captions"?: true}` | PDF с миниатюрами, подписи это имена файлов. `paper` бывает `a4` или `letter`, `columns` от 1 до 8, `rows` от 1 до 10. От 1 до 1000 кадров, не больше 100 страниц. Лишний ключ это ошибка |
| `faces.detect` | `{"ids"?, "apply"?: true}` | Находит лица. Нужна модель YuNet: `faces.models.download {"id": "yunet-2023mar", "acknowledged": true}`, только с согласия человека |

## Проявка

| Команда | Параметры | Что делает |
|---|---|---|
| `develop.wb` | `{"mode": "asShot", "temp"?, "tint"?}` | Баланс белого активного кадра. `mode`: `asShot`, `auto`, `daylight`, `cloudy`, `shade`, `tungsten`, `fluorescent`, `flash`, `custom` |
| `develop.wbPick` | `{"x": 0.1, "y": 0.1}` | Пипетка по нейтральной точке активного кадра. `x` и `y` это доли от 0 до 1 от левого верхнего угла всего кадра |
| `develop.auto` | `{"ids"?}` | Автонастройка: ставит exposure, contrast, highlights, shadows, whites, blacks, vibrance, saturation. Отвечает этими числами для первого кадра |
| `develop.set` | `{"values": {"light.exposure": 0.3}, "ids"?}` или `{"control": "light.exposure", "value": 0.3}` | Ставит ползунки. Без `ids` только активный кадр. Значение вне пределов обрезается до предела |
| `develop.quickAdjust` | `{"control": "light.exposure", "delta": 0.2, "ids"?}` | Прибавляет `delta` к своему значению каждого кадра |
| `develop.merge` | `{"settings": {"optics": {"lens_profile": true}}}` | Вливает часть настроек в JSON в активный кадр. Ключи разделов пишутся через подчёркивание, как в `develop.get` |
| `develop.sync` | `{"groups"?: […]}` | Копирует настройки активного кадра на все выделенные |
| `develop.matchExposure` | `{"ids"?}` | Подгоняет Exposure каждого выделенного кадра под активный по выдержке, диафрагме и ISO из файла. Кадры без этих данных пропускает. Отвечает `changed`, `skipped` |
| `develop.resetControl` | `{"control": "color.saturation"}` | Один ползунок активного кадра по умолчанию |
| `develop.reset` | `{"ids"?}` | Все правки кадров к виду после импорта |
| `crop.straighten` | `{"angle": -45..45}` | Поворот активного кадра в градусах |
| `crop.autoStraighten` | `{}` | Выравнивает горизонт активного кадра по линиям. Отвечает `angle` или `changed: false` |
| `crop.reset` | `{}` | Снимает кадрирование и поворот активного кадра |

Группы настроек для `develop.sync`, `develop.copy` и `preset.create`: `profile`, `treatment`, `whiteBalance`, `light`, `toneCurve`, `color`, `colorMixer`, `colorGrading`, `effects`, `vignette`, `grain`, `detail`, `optics`, `geometry`, `crop`, `masks`, `spots`, `redEye`, `lensBlur`, `calibration`. По умолчанию копируется всё, кроме `crop`, `masks`, `spots`, `redEye`.

## Пресеты

| Команда | Параметры | Что делает |
|---|---|---|
| `preset.create` | `{"name": "…", "group"?, "groups"?: […]}` | Пресет из активного кадра. Отвечает `{"id": …}` |
| `preset.apply` | `{"id": "…", "amount"?: 100, "ids"?}` | Применяет пресет к `ids` или к выделенным, `amount` от 0 до 200 процентов |
| `presets.list` | `{}` | Все пресеты с `id` |
| `preset.export` | `{"path": "…/вид.lcpreset", "ids": ["…"]}` | Сохраняет пресеты в файл `.lcpreset` |
| `preset.import` | `{"paths": ["…/вид.lcpreset"]}` | Читает пресеты. Новые `id` в `imported` |

## Экспорт

`app.export` пишет выделенные кадры, если их больше одного, иначе кадр `id` или активный.

| Ключ | Значения | По умолчанию |
|---|---|---|
| `path` или `dir` | один файл или папка для партии | |
| `ids`, `id` | какие кадры | выделенные |
| `format` | `jpeg`, `png`, `tiff`, `psd`, `webp`, `avif`, `jxl`, `dng` | по расширению `path`, иначе `jpeg` |
| `longEdge`, `shortEdge`, `width`, `height`, `percent` | размер, `longEdge` 0 это полный размер | длинная сторона 3000 |
| `dontEnlarge` | `true`, `false` | `true` |
| `quality` | от 1 до 100 | 90 |
| `limitKb` | наибольшее качество JPEG, при котором файл не тяжелее стольких КБ | нет |
| `sharpen`, `sharpenAmount` | `none`, `screen`, `matte`, `glossy`; `low`, `standard`, `high` | `none`, `standard` |
| `colorSpace` | `srgb`, `displayP3`, `adobeRgb`, `proPhoto`, `rec2020` | `srgb` |
| `bitDepth` | JPEG 8, TIFF 8, 16 или 32, PNG 8 или 16 | TIFF 16 |
| `metadata` | `all`, `allExceptCamera`, `copyright`, `none` (профиль sRGB остаётся) | `all` |
| `naming` | `{name}` имя исходника, `{seq}`, `{seq:3}`, `{date}`, `{rating}`, `{camera}` | `{name}` |
| `conflict` | `unique`, `overwrite`, `skip` | `unique` |

Один файл без каталога: `lightcraft-cli render вход.jpg -o выход.jpg --size 1600 --quality 90 --set light.exposure=0.3 --settings вид.lcpreset --opt metadata=none`. Без `--size` полный размер, качество по умолчанию 92. `--settings` берёт файл с одним пресетом.

## Ползунки для съёмки

| id | Пределы | По умолчанию |
|---|---|---|
| `wb.temp` | 2000..50000 | 6500. На JPEG 6500 значит как снято, больше теплее, меньше холоднее |
| `wb.tint` | -150..150 | 0. Минус зеленее, плюс пурпурнее |
| `light.exposure` | -5..5 в ступенях | 0 |
| `light.contrast`, `light.highlights`, `light.shadows`, `light.whites`, `light.blacks` | -100..100 | 0 |
| `color.vibrance`, `color.saturation` | -100..100 | 0 |
| `curve.highlights`, `curve.lights`, `curve.darks`, `curve.shadows` | -100..100 | 0 |
| `effects.texture`, `effects.clarity`, `effects.dehaze` | -100..100 | 0 |
| `detail.sharpenAmount` | 0..150 | 0, у RAW после импорта 40 |
| `detail.sharpenRadius` | 0.5..3 | 1 |
| `detail.sharpenDetail`, `detail.sharpenMasking` | 0..100 | 25, 0 |
| `detail.nrLuminance`, `detail.nrColor` | 0..100 | 0, у RAW цветовой шум 25 |
| `optics.profileDistortion`, `optics.profileVignetting` | 0..200 | 100 |
| `optics.distortion`, `optics.vignetting` | -100..100 | 0 |
| `geometry.vertical`, `geometry.horizontal` | -100..100 | 0 |
| `geometry.rotate` | -10..10 | 0 |
| `crop.angle` | -45..45 | 0 |

Профиль объектива и хроматические аберрации включаются не ползунком: `develop.merge` с `{"optics": {"lens_profile": true, "remove_ca": true}}`. Профили объектива LightCraft применяет только к RAW.
