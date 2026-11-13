# Команды PhotoCraft для обработки фото одежды

Сверено с исходным кодом PhotoCraft 0.23.1. Перед работой проверь нужную команду в установленной версии: `photocraft-cli commands --filter <слово>`.

Запись `"ключ": тип = значение` означает значение по умолчанию. Параметры со знаком `?` можно не указывать.

## Фон и выделение

| Команда | Параметры | Что делает |
|---|---|---|
| `layer.removeBackground` | `{"layer": id?, "sampleAllLayers": false, "refine": true}` | Находит предмет и прячет фон маской слоя. Пиксели не удаляет. Возвращает `{layer, bounds}`, где `bounds` это `[x, y, ширина, высота]` предмета |
| `select.subject` | `{"sampleAllLayers": false, "mode": "replace"}` | Выделяет предмет, фон не трогает |
| `layer.flattenImage` | `{}` | Сводит все слои в один. Прозрачные места становятся белыми |
| `layer.newFillLayer.solidColor` | `{"color": "#rrggbb"}` | Новый слой сплошного цвета над активным |
| `layer.arrange.sendToBack` | `{"layer": id?}` | Опускает слой в самый низ |
| `edit.fill` | `{"contents": "color", "color": "#rrggbb"}` | Заливает слой или выделение. `contents` бывает `white`, `black`, `gray`, `contentAware` |

## Размер и кадр

| Команда | Параметры | Что делает |
|---|---|---|
| `image.trim` | `{"basedOn": "transparent", "top": true, "bottom": true, "left": true, "right": true}` | Обрезает пустые края. `basedOn` бывает `transparent`, `topLeft`, `bottomRight` |
| `image.crop` | `{"x", "y", "width", "height", "targetWidth"?, "targetHeight"?, "resample": "bicubic"}` | Обрезает по прямоугольнику. С `targetWidth` и `targetHeight` сразу приводит к точному размеру. Без координат обрезает по текущему выделению |
| `file.automate.fitImage` | `{"width", "height", "dontEnlarge": false, "resample": "bicubic"}` | Вписывает изображение в рамку с сохранением пропорций |
| `image.imageSize` | `{"width"?, "height"?, "percent"?, "resolution"?, "resample": "bicubic"}` | Меняет размер. Возвращает `{width, height}` |
| `image.canvasSize` | `{"width", "height", "units": "px", "relative": false, "anchor": "center", "extensionColor": "background"}` | Меняет холст без масштабирования картинки. `extensionColor` бывает `white`, `black`, `transparent`, `#rrggbb`. Холст меньше картинки обрезает её вокруг точки `anchor` |
| `image.rotation.arbitrary` | смотри `commands --filter rotation` | Поворот на угол, чтобы выровнять горизонт |

`resample` бывает `bicubic`, `bicubicSharper` (для уменьшения), `bicubicSmoother` (для увеличения), `lanczos`, `preserveDetails`, `bilinear`, `nearest`.

## Свет и цвет

Каждая настройка есть в двух видах: `image.adjustments.<имя>` меняет пиксели, `layer.newAdjustmentLayer.<имя>` кладёт корректирующий слой. Для пакетной обработки в JPEG разницы в результате нет.

| Имя | Параметры |
|---|---|
| `levels` | `{"inBlack": 0, "gamma": 1, "inWhite": 255, "outBlack": 0, "outWhite": 255}`. `gamma` больше 1 светлее, меньше 1 темнее |
| `curves` | `{"points": [[0,0],[64,56],[192,200],[255,255]]}`, от 2 до 19 точек в шкале 0..255 |
| `brightnessContrast` | `{"brightness": -150..150, "contrast": -50..100}` |
| `exposure` | `{"exposure": -20..20, "offset": -0.5..0.5, "gamma": 1}` |
| `vibrance` | `{"vibrance": -100..100, "saturation": -100..100}` |
| `hueSaturation` | `{"hue": -180..180, "saturation": -100..100, "lightness": -100..100}` |
| `colorBalance` | `{"shadows": [к-к, п-з, ж-с], "midtones": […], "highlights": […]}`, каждое число -100..100 |
| `photoFilter` | `{"filter": "warming85", "density": 0..100}`. Фильтры: `warming85`, `warmingLBA`, `warming81`, `cooling80`, `coolingLBB`, `cooling82` и цветные |
| `shadowsHighlights` | `{"shadowAmount": 0..100, "highlightAmount": 0..100}`, только `image.adjustments` |
| `colorLookup` | `{"file": "путь к .cube"}` или `{"lut": "warm"}`. Встроенные: `warm`, `cool`, `tealOrange`, `bleachBypass`, `fadedFilm`, `monoContrast`, `crossProcess` |

Автоматика без параметров: `image.autoContrast` (растягивает контраст, цвет не сдвигает), `image.autoTone` (по каналам, может сдвинуть цвет), `image.autoColor` (убирает цветовой оттенок).

Резкость:

| Команда | Параметры |
|---|---|
| `filter.sharpen.unsharpMask` | `{"amount": 1..500, "radius": 0.1..1000, "threshold": 0..255}` |
| `filter.sharpen.smartSharpen` | `{"amount": 1..500, "radius": 0.1..64, "reduceNoise": 0..100}` |

## Цветовой профиль и сохранение

| Команда | Параметры | Что делает |
|---|---|---|
| `edit.convertToProfile` | `{"profile": "srgb"}` | Переводит цвета в профиль. Для сайтов, соцсетей и маркетплейсов нужен sRGB |
| `file.export.colorLookupTables` | `{"size": 33, "path": "образ.cube"}` | Сохраняет видимые корректирующие слои как таблицу цвета .cube |
| `image.duplicate` | `{}` | Копия документа для опытов, оригинал не меняется |
| `edit.undo` | `{}` | Шаг назад |

Формат и качество файла задаются ключами самой утилиты: `--format jpg|png|webp|tif`, `--quality 1-100`, `--metadata none|all`, `--jpeg-format baseline|optimized|progressive`.

## Готовые пакетные инструменты

| Команда | Параметры | Что делает |
|---|---|---|
| `file.scripts.imageProcessor` | `{"source": "folder", "input": "папка", "output": "папка", "format": "jpg", "quality": 0..12, "width"?, "height"?, "convertToSrgb": false}` | Уменьшает и сохраняет папку, никогда не увеличивает |
| `file.automate.batch` | `{"input", "output", "steps", "format", "naming", "startingSerial"}` | То же, что `photocraft-cli batch`, но как команда движка |
