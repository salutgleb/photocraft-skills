# Команды PhotoCraft для обработки фото одежды

Сверено с исходным кодом PhotoCraft 0.23.1. Ни одна команда отсюда не запускалась вживую: всё взято из исходного кода. Перед работой проверь нужную команду в установленной версии: `photocraft-cli commands --filter <слово>`.

Запись `"ключ": тип = значение` означает значение по умолчанию. Параметры со знаком `?` можно не указывать.

## Фон и выделение

| Команда | Параметры | Что делает |
|---|---|---|
| `layer.removeBackground` | `{"layer": id?, "sampleAllLayers": false, "refine": true}` | Находит предмет и прячет фон маской слоя. Пиксели не удаляет. Возвращает `{layer, bounds}`, где `bounds` это `[x, y, ширина, высота]` предмета |
| `select.subject` | `{"sampleAllLayers": false, "mode": "replace"}` | Выделяет предмет, фон не трогает |
| `layer.flattenImage` | `{}` | Сводит все слои в один. Прозрачные места становятся белыми |
| `layer.newFillLayer.solidColor` | `{"color": "#rrggbb"}` | Новый слой сплошного цвета над активным |
| `layer.arrange.sendToBack` | `{"layer": id?}` | Опускает слой в самый низ |
| `edit.fill` | `{"contents": "color", "color": "#rrggbb", "opacity": 0..100 = 100, "mode": "normal"}` | Заливает слой или выделение. `contents` бывает `color`, `foreground`, `background`, `white`, `black`, `gray`, `pattern`, `history`, `contentAware` |

## Размер и кадр

| Команда | Параметры | Что делает |
|---|---|---|
| `image.trim` | `{"basedOn": "transparent", "top": true, "bottom": true, "left": true, "right": true}` | Обрезает пустые края. `basedOn` бывает `transparent`, `topLeft`, `bottomRight` |
| `image.crop` | `{"x", "y", "width", "height", "targetWidth"?, "targetHeight"?, "angle": -3600..3600 = 0, "resample": "bicubic"}` | Обрезает по прямоугольнику. С `targetWidth` и `targetHeight` сразу приводит к точному размеру. Без координат обрезает по текущему выделению. Ключа пропорции нет: прямоугольник считаешь сам |
| `file.automate.fitImage` | `{"width", "height", "dontEnlarge": false, "resample": "bicubic"}` | Вписывает изображение в рамку с сохранением пропорций |
| `image.imageSize` | `{"width"?, "height"?, "percent"?, "resolution"?, "resample": "bicubic"}` | Меняет размер. Возвращает `{width, height}` |
| `image.canvasSize` | `{"width", "height", "units": "px", "relative": false, "anchor": "center", "extensionColor": "background"}` | Меняет холст без масштабирования картинки. `extensionColor` бывает `white`, `black`, `transparent`, `#rrggbb`. Холст меньше картинки обрезает её вокруг точки `anchor` |
| `image.rotation.arbitrary` | `{"angle": -359.99..359.99 = 0, "direction": "cw", "interpolation": "bicubic"}` | Поворот на угол, чтобы выровнять горизонт. `direction` бывает `cw` и `ccw`, `interpolation` бывает `bicubic`, `bilinear`, `nearest` |

`resample` у `image.imageSize` и `file.automate.fitImage`: `bicubic`, `bicubicSharper` (для уменьшения), `bicubicSmoother` (для увеличения), `bicubicAutomatic`, `automatic`, `lanczos`, `preserveDetails`, `bilinear`, `nearest`. У `image.crop` список короче: `bicubic`, `bilinear`, `nearest`, `lanczos`, `preserveDetails`.

## Свет и цвет

Каждая настройка есть в двух видах: `image.adjustments.<имя>` меняет пиксели, `layer.newAdjustmentLayer.<имя>` кладёт корректирующий слой. Для пакетной обработки в JPEG разницы в результате нет. При активном выделении `image.adjustments.<имя>` меняет только выделенное, а новый корректирующий слой получает выделение как маску.

| Имя | Параметры |
|---|---|
| `levels` | `{"inBlack": 0, "gamma": 1, "inWhite": 255, "outBlack": 0, "outWhite": 255}`. `gamma` больше 1 светлее, меньше 1 темнее |
| `curves` | `{"points": [[0,0],[64,56],[192,200],[255,255]]}`, от 2 до 19 точек в шкале 0..255. Для отдельного канала ключи `red`, `green`, `blue` с тем же видом точек |
| `brightnessContrast` | `{"brightness": -150..150, "contrast": -50..100}` |
| `exposure` | `{"exposure": -20..20, "offset": -0.5..0.5, "gamma": 1}` |
| `vibrance` | `{"vibrance": -100..100, "saturation": -100..100}` |
| `hueSaturation` | `{"hue": -180..180, "saturation": -100..100, "lightness": -100..100}` |
| `colorBalance` | `{"shadows": [к-к, п-з, ж-с], "midtones": […], "highlights": […]}`, каждое число -100..100 |
| `photoFilter` | `{"filter": "warming85", "density": 0..100}`. Фильтры: `warming85`, `warmingLBA`, `warming81`, `cooling80`, `coolingLBB`, `cooling82` и цветные |
| `shadowsHighlights` | `{"shadowAmount": 0..100, "highlightAmount": 0..100}`, только `image.adjustments` |
| `colorLookup` | `{"file": "путь к .cube"}`, или `{"data": "текст .cube"}`, или `{"lut": "warm"}`. Встроенные: `warm`, `cool`, `tealOrange`, `bleachBypass`, `fadedFilm`, `dayForNight`, `monoContrast`, `crossProcess`. `data` нужен в режиме MCP: там путь `file` запрещён |

Автоматика без параметров: `image.autoContrast` (растягивает контраст, цвет не сдвигает), `image.autoTone` (по каналам, может сдвинуть цвет), `image.autoColor` (убирает цветовой оттенок).

**Баланс белого по нейтральной точке.** У `levels` и `curves` есть пипетка: `{"eyedropper": {"point": "gray", "at": [x, y], "size": 1..101 = 1}}`. Точка `at` должна лежать на том, что в жизни серое: фон из серой бумаги, серая карта. `size` усредняет квадрат вокруг точки, бери 11 или 31. `point` бывает `black`, `gray`, `white`.

**`filter.cameraRaw`.** Проявка как в Camera Raw для обычного фото. Все числа от -100 до 100, если не сказано иное: `temperature`, `tint`, `exposure` (-5..5), `contrast`, `highlights`, `shadows`, `whites`, `blacks`, `texture`, `clarity`, `dehaze`, `vibrance`, `saturation`, `vignetteAmount` (отрицательное затемняет углы, положительное осветляет; проверь на пробе), `vignetteMidpoint` (0..100 = 50). Действует внутри выделения, если оно есть.

## Резкость, шум, сглаживание

Все фильтры действуют на активный слой и только внутри выделения, если оно есть.

| Команда | Параметры |
|---|---|
| `filter.sharpen.unsharpMask` | `{"amount": 1..500, "radius": 0.1..1000, "threshold": 0..255}` |
| `filter.sharpen.smartSharpen` | `{"amount": 1..500, "radius": 0.1..64, "reduceNoise": 0..100}` |
| `filter.blur.surfaceBlur` | `{"radius": 1..100 = 5, "threshold": 2..255 = 15}`. Сглаживает мелкие перепады, резкие границы оставляет |
| `filter.noise.median` | `{"radius": 1..500 = 1}`. Убирает мелкие точки |
| `filter.noise.dustAndScratches` | `{"radius": 1..500 = 1, "threshold": 0..255 = 0}` |
| `filter.blur.gaussianBlur` | `{"radius": 0.1..1000 = 1}` |
| `filter.noise.reduceNoise` | `{"strength": 0..10 = 6, "preserveDetails": 0..100 = 60, "reduceColorNoise": 0..100 = 45, "sharpenDetails": 0..100 = 25, "removeJpegArtifact": false}` |
| `filter.noise.addNoise` | `{"amount": 0.1..400 = 12.5, "distribution": "uniform", "monochromatic": false, "seed": 0}`. `distribution` бывает `uniform` и `gaussian` |

## Выделение и маски

| Команда | Параметры | Что делает |
|---|---|---|
| `select.subject` | см. выше | Выделение считается по цвету и контрасту, без нейросети. Ничего не нашёл: выделение не меняется |
| `select.inverse` | `{}` | Переворачивает выделение |
| `select.deselect` | `{}` | Снимает выделение |
| `select.modify.expand` | `{"radius": 1..500 = 1}` | Расширяет выделение |
| `select.modify.contract` | `{"radius": 1..500 = 1}` | Сужает выделение |
| `select.modify.feather` | `{"radius": 0.1..1000 = 1}` | Смягчает край |
| `select.modify.smooth` | `{"radius": 1..500 = 1}` | Скругляет неровный край |
| `select.rect` | `{"x", "y", "width", "height", "mode": "replace", "ellipse": false, "feather": 0}` | Прямоугольник или эллипс. `mode` бывает `replace`, `add`, `subtract`, `intersect` |
| `select.colorRange` | `{"select": "sampledColors", "points": [[x, y], …]?, "fuzziness": 0..200 = 40, "mode": "replace"}` | Выделение по цвету. `select` бывает также `skinTones`, `highlights`, `midtones`, `shadows`, `reds` и другие цвета |
| `layer.layerMask.revealSelection` | `{"layer": id?}` | Маска слоя из выделения: видно выделенное |
| `layer.layerMask.hideSelection` | `{"layer": id?}` | Маска слоя из выделения: выделенное скрыто |

Команды `select.modify.*` и `select.inverse` требуют выделения. Без него они падают с ошибкой `no selection`.

## Ретушь по координатам

Общие ключи кисти: `"points": [[x, y], …]` в пикселях кадра, `"size": 1..5000`, `"hardness": 0..100`. Точки одной команды соединяются в один мазок.

| Команда | Параметры | Что делает |
|---|---|---|
| `paint.spotHealing` | кисть плюс `"type": "contentAware"` | Убирает пятно под мазком. `type` бывает `contentAware`, `createTexture`, `proximityMatch` |
| `paint.remove` | кисть плюс `"closeLoops": true`, `"newLayer": false` | Убирает то, что обведено мазком |
| `edit.contentAwareFill` | `{"sampling": "auto", "output": "current", "seed": 1}` | Заливает выделение по окружению. Без выделения не работает |

## Измерения без сохранения

Эти команды ничего не меняют. Запускай их через `run` без `--out`, ответ печатается.

| Команда | Параметры | Что возвращает |
|---|---|---|
| `document.inspect` | `{}` | `width`, `height`, `resolution`, `hasSelection`, `selectionBounds` `[x, y, ширина, высота]` и слои с полем `bounds` |
| `document.sampleColor` | `{"x", "y", "size": 1}` | `[r, g, b, a]` от 0 до 1. `size` бывает `point`, 1, 3, 5, 11, 31, 51, 101: среднее по квадрату |
| `document.pixel` | `{"x", "y"}` | Один пиксель итоговой картинки |
| `image.detectFaces` | `{"minScore": 0..1 = 0.5}` | Лица: `rect` `[x, y, ширина, высота]` и точки глаз, носа, рта |

После `select.subject` команда `document.inspect` даёт в `selectionBounds` рамку человека или предмета.

## Компоновка

| Команда | Параметры | Что делает |
|---|---|---|
| `file.placeEmbedded` | `{"path", "scale": %?, "center": [x, y]?, "smartObject": true}` | Кладёт файл слоем. `scale` в процентах, `center` это центр кадра в пикселях холста. Без `scale` уменьшает, только если файл больше холста. Возвращает `scale` и `bounds` `[x0, y0, x1, y1]` |
| `layer.translate` | `{"layer": id?, "dx", "dy"}` | Сдвигает слой на целые пиксели |
| `layer.align.leftEdges` и другие | `{"to": "auto"}` | Выравнивает слои. `to` бывает `auto`, `layers`, `selection`, `canvas`. Есть `topEdges`, `verticalCenters`, `bottomEdges`, `horizontalCenters`, `rightEdges` |
| `type.create` | `{"x", "y", "text", "font": "Inter", "size": 12, "color": "#rrggbb", "align"?}` | Текстовый слой. `x` и `y` это точка на базовой линии, `size` в пунктах. `align` бывает `left`, `center`, `right`; с `center` текст стоит по центру точки `x`. `Inter` встроен и есть всегда, он же ставится вместо неизвестного шрифта. Список шрифтов: `type.fonts` |
| `file.automate.contactSheetII` | `{"input": папка или список, "units": "pixels", "width", "height", "resolution", "columns": 5, "rows": 6, "caption": true, "fontSize": 12, "flatten": false}` | Лист с кадрами и именами. Каждая страница это новый документ. `--out` у `run` сохраняет только последнюю |

Документ с нуля: `photocraft-cli run --new '{"width":2520,"height":1980,"background":"white"}'`. Ключи те же, что у `file.new`. Разрешение по умолчанию 72, поэтому размер текста в пунктах равен размеру в пикселях.

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

Файл для `photocraft-cli batch --actions` бывает таким:

- список пар `[["команда", {параметры}], …]`, список `{"command", "params"}` или имён команд;
- тот же список внутри `{"steps": …}` или `{"actions": …}`;
- набор экшенов `{"actions": [{"name", "steps"}, …]}`, тогда ключ `--action имя` выбирает экшен;
- файл экшенов Фотошопа `.atn`. Шаги, которых PhotoCraft не знает, остаются в наборе, и проигрывание на них останавливается.

Имя по шаблону `--naming` задаёт имя файла целиком, вместе с расширением. Пиши `--naming '{name}_{serial}.{ext}'`. Без `.{ext}` файлы выйдут без расширения. `{serial}` даёт три цифры, `{serial:1}`…`{serial:4}` своё число цифр.

## Известные ограничения

- У `run` нет предпросмотра. Чтобы посмотреть результат, сохрани PNG или JPEG через `--out` в `_проба` и открой его.
- В `batch` шаги одинаковые для всех файлов. Параметров для отдельного файла нет. Всё, что требует координат, делай по одному файлу через `run`.
- В справке PhotoCraft записана открытая ошибка: «A recorded **Image Size** step applies the first file's size to the other files in a batch» (#11721, #11722). Если в партии есть шаг размера, проверь размеры нескольких результатов через `info`.
- В режиме MCP команды `file.*` с путями к файлам запрещены, кроме `file.new` и нескольких команд без путей. Открывать и сохранять там нужно инструментами `doc_open`, `doc_place`, `doc_save`. `colorLookup` с ключом `file` там тоже запрещён.
