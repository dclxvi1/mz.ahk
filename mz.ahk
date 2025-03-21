#SingleInstance Force
#IfWinActive MTA
CheckUIA()
{
    if (!A_IsCompiled && !InStr(A_AhkPath, "_UIA")) {
        Run % "*uiAccess " A_ScriptFullPath
        ExitApp
    }
}

if !A_IsUnicode
{
    MsgBox, Этот скрипт требует AHK Unicode версии. Пожалуйста, используйте версию AHK Unicode.
    ExitApp
}

if not A_IsAdmin
{
    Run *RunAs "%A_ScriptFullPath%"  
    ExitApp 
}

global Tag :=  "", Partners := "" , City := "" , Post := "" , Frac := "" , FIO :="", Rang :="" , Disc := "" , Colors := ""
;________________________________________________________________________________________________________________________________________________________________________________________

scriptPath := A_ScriptFullPath
scriptDir := A_ScriptDir
scriptName := A_ScriptName
currentVersion := "0.8.5"
githubVersionURL := "https://raw.githubusercontent.com/dclxvi1/mz.ahk/refs/heads/main/version"
githubScriptURL := "https://raw.githubusercontent.com/dclxvi1/mz.ahk/refs/heads/main/mz.ahk"
githubChangelogURL := "https://raw.githubusercontent.com/dclxvi1/mz.ahk/refs/heads/main/changelog.txt"

CheckForUpdates() {
    global currentVersion, githubVersionURL, githubScriptURL, githubChangelogURL, scriptPath, scriptDir, scriptName
    whr := ComObjCreate("WinHttp.WinHttpRequest.5.1")
    whr.Open("GET", githubVersionURL, true)
    whr.Send()
    whr.WaitForResponse()
    status := whr.Status
    if (status != 200) {
        MsgBox, 16, Ошибка, Не удалось получить версию с сервера. Код статуса: %status%
        return
    }
    serverVersion := Trim(whr.ResponseText)
    serverVersion := RegExReplace(serverVersion, "[\r\n]+", "")
    serverVersion := RegExReplace(serverVersion, "\s+", "")
    currentVersion := Trim(currentVersion)
    currentVersion := RegExReplace(currentVersion, "[\r\n]+", "")
    currentVersion := RegExReplace(currentVersion, "\s+", "")
    if (serverVersion != currentVersion) {
        MsgBox, 4, Обновление, Доступна новая версия (%serverVersion%). Хотите обновить?
        IfMsgBox, No
            return
        whr.Open("GET", githubChangelogURL, true)
        whr.Send()
        whr.WaitForResponse()
        status := whr.Status
        if (status != 200) {
            MsgBox, 16, Ошибка, Не удалось получить информацию об изменениях. Код статуса: %status%
            return
        }
        changelog := whr.ResponseText
        whr.Open("GET", githubScriptURL, true)
        whr.Send()
        whr.WaitForResponse()
        status := whr.Status
        if (status != 200) {
            MsgBox, 16, Ошибка, Не удалось загрузить новый скрипт. Код статуса: %status%
            return
        }
        newScript := whr.ResponseText
        oldScriptPath := scriptDir "\" RegExReplace(scriptName, "\.ahk$", "") " (old).ahk"
        FileMove, %scriptPath%, %oldScriptPath%
        FileAppend, %newScript%, %scriptPath%
        currentVersion := serverVersion

        MsgBox, 64, Скрипт обновлен, Скрипт успешно обновлен до версии %serverVersion%.`n`nОбновления:`n%changelog%
        ExitApp
    }
}
CheckForUpdates()
;________________________________________________________________________________________________________________________________________________________________________________________
folderPath := "C:\Program Files\mz.ahk"
iniFile := folderPath "\settings.ini"
ServerAddress := "185.71.66.70:22003"

IniWrite(Value, iniFile, Section, Key) {
  IniWrite, %Value%, %iniFile%, %Section%, %Key%
}

GetIniValue(Key) {
    IniRead, Value, %iniFile%, %Section%, %Key%
    return Value
}


EnsureFolderExists() {
    global folderPath
    if !FileExist(folderPath)
    {
        FileCreateDir, %folderPath%
        if ErrorLevel
        {
            MsgBox, 16, Ошибка, Не удалось создать папку: %folderPath%
            return false
        }
        else
        {
            MsgBox, 64, Успех, Папка успешно создана: %folderPath%
            return true
        }
    }
    return true
}
if !EnsureFolderExists()
{
    ExitApp  ; Завершаем скрипт, если папку не удалось создать
}

  If Not FileExist("C:\Windows\Fonts\Gilroy-Medium.ttf")
  {
    MsgBox, Шрифт "Gilroy" не найден! Пожалуйста, установите нужные шрифты, согласно гайду.
ExitApp
}
;________________________________________________________________________________________________________________________________________________________________________________________
folderPath := "C:\Program Files\mz.ahk"
icoURL := "https://raw.githubusercontent.com/dclxvi1/mz.ahk/refs/heads/main/helper.ico"
icoPath := folderPath "\helper.ico"
testFile := folderPath "\test.tmp"
try
{
    FileAppend, Тест прав доступа, %testFile%
    FileDelete, %testFile%
}
catch
{
    MsgBox, 16, Ошибка, Нет прав на запись в папку: %folderPath%. Запустите скрипт от имени администратора.
    ExitApp
}

IfExist, C:\Program Files\mz.ahk\mz.ico
{
} else {
URLDownloadToFile, %icoURL%, %icoPath%
if ErrorLevel
{
    MsgBox, 16, Ошибка, Не удалось загрузить иконку. Код ошибки: %ErrorLevel%
}
}
pathicon := "C:\Program Files\mz.ahk\helper.ico"
Menu, Tray, Icon, %pathicon%

CheckUIA()
Gui, Color, 202127
Gui, Show, center w710 h600, mz helper
;________________________________________________________________________________________________________________________________________________________________________________________

LoadData()
Gui 1:Font, s12 cWhite Bold, Gilroy
Gui 1:Add, Tab2, x8 y5 h40 w600 Buttons -Wrap, main|доклады|лекции|бал.система|фиксац.
Gui 1:Font, s11 cWhite Bold, Gilroy
Gui, Add, Button, x580 y10 w120 h30 gData, settings
Gui, Add, Button, x435 y10 w140 h30 gUseLink, Полезные ссылки
Gui, Add, Button, x237 y470 w465 h30 grungame, Запуск игры [ укажите диск, на котором установлена игра ]
Gui, Add, Button, x237 y505 w465 h30 gkillgame, Остановка игры [ полное её закрытие ]
Gui 1:Font, s12 cWhite Bold, Gilroy
Gui 1:Add, GroupBox, x10 y40 w225 h75 ; рамка для границ
Gui 1:Add, GroupBox, x10 y40 w225 h135 ; рамка для границ
Gui 1:Add, GroupBox, x10 y40 w225 h270 c%Colors%, [ общие ]
Gui 1:Font, s8 White Bold, Gilory
Gui, Add, Text, x2 x20 y65 w111 h15 cWhite, • смена1
Gui, Add, Text, x2 x67 y65 w150 h15 c%Colors%, — fracvoice 2 + доклады
Gui, Add, Text, x2 x20 y80 w150 h15 cWhite, • смена2
Gui, Add, Text, x2 x67 y80 w150 h15 c%Colors%, — доклад о сдаче смены
Gui, Add, Text, x2 x20 y95 w150 h15 cWhite, • рация1
Gui, Add, Text, x2 x68 y95 w150 h15 c%Colors%, — исп. раций ( r | ro | d )

Gui, Add, Text, x2 x20 y120 w100 h15 cWhite, • медкарта1
Gui, Add, Text, x2 x85 y120 w120 h15 c%Colors%, — вводная часть выдачи
Gui, Add, Text, x2 x20 y135 w100 h15 cWhite, • медпсих1
Gui, Add, Text, x2 x78 y135 w155 h15 c%Colors%, — проверка псих. состояния
Gui, Add, Text, x2 x20 y150 w100 h15 cWhite, • медфиз1
Gui, Add, Text, x2 x73 y150 w150 h15 c%Colors%, — проверка физ. состояния

Gui, Add, Text, x2 x20 y180 w111 h15 cWhite, • ctrl + 1
Gui, Add, Text, x2 x65 y180 w150 h15 c%Colors%, — приветствие
Gui, Add, Text, x2 x20 y195 w150 h15 cWhite, • ctrl + 2
Gui, Add, Text, x2 x65 y195 w150 h15 c%Colors%, — фраза "чем могу помочь"
Gui, Add, Text, x2 x20 y210 w150 h15 cWhite, • ctrl + 3
Gui, Add, Text, x2 x65 y210 w150 h15 c%Colors%, — фраза "выпишу вам миг"
Gui, Add, Text, x2 x20 y225 w150 h15 cWhite, • ctrl + 4
Gui, Add, Text, x2 x65 y225 w160 h15 c%Colors%, — выдача лекарства
Gui, Add, Text, x2 x20 y240 w150 h15 cWhite, • ctrl + 5
Gui, Add, Text, x2 x65 y240 w160 h15 c%Colors%, — самолечение

Gui 1:Font, s12 cWhite Bold, Gilroy
Gui 1:Add, GroupBox, x237 y40 w465 h138 c%Colors%, [ вызов ]
Gui 1:Font, s8 White Bold, Gilory
Gui, Add, Text, x247 y65 w222 h15 c%Colors%, • вызов1
Gui, Add, Text, x295 y65 w300 h15 cWhite, — доклад о принятии | прибытии | госпитализации
Gui, Add, Text, x247 y80 w343 h15 cwhite, | отмене | ложном вызове | обработке вызова на месте ( СОЛО )
Gui, Add, Text, x247 y95 w222 h15 c%Colors%, • вызовн1
Gui, Add, Text, x300 y95 w300 h15 cWhite, — доклад о принятии | прибытии | госпитализации
Gui, Add, Text, x247 y110 w393 h15 cWhite, | отмене | ложном вызове | обработке вызова на месте ( С НАПАРНИКОМ )
Gui, Add, Text, x247 y125 w210 h15 c%Colors%, • созн1
Gui, Add, Text, x286 y125 w210 h15 cWhite, — приведение в сознание пациента
Gui, Add, Text, x247 y140 w210 h15 c%Colors%, • alt + 1
Gui, Add, Text, x292 y140 w288 h15 cWhite, — каталка
Gui, Add, Text, x247 y155 w210 h15 c%Colors%, • alt + 2
Gui, Add, Text, x292 y155 w288 h15 cWhite, — госпитализация

Gui 1:Font, s12 cWhite Bold, Gilroy
Gui 1:Add, GroupBox, x10 y305 w225 h245 c%Colors%, [ лекарства ]
Gui 1:Font, s8 White Bold, Gilory
Gui, Add, Text, x2 x20 y330 w70 h15 cWhite, • живот1
Gui, Add, Text, x2 x20 y345 w70 h15 cWhite, • тошнота1
Gui, Add, Text, x2 x20 y360 w90 h15 cWhite, • отравление1
Gui, Add, Text, x2 x20 y375 w70 h15 cWhite, • ушиб1
Gui, Add, Text, x2 x20 y390 w70 h15 cWhite, • обезбол1
Gui, Add, Text, x2 x20 y405 w70 h15 cWhite, • запор1
Gui, Add, Text, x2 x20 y420 w70 h15 cWhite, • понос1
Gui, Add, Text, x2 x20 y435 w70 h15 cWhite, • геморрой1
Gui, Add, Text, x2 x20 y450 w70 h15 cWhite, • суставы1
Gui, Add, Text, x2 x20 y465 w70 h15 cWhite, • судороги1
Gui, Add, Text, x2 x20 y480 w70 h15 cWhite, • витамины1
Gui, Add, Text, x2 x20 y495 w70 h15 cWhite, • аллергия1
Gui, Add, Text, x2 x20 y510 w70 h15 cWhite, • простуда1
Gui, Add, Text, x2 x20 y525 w70 h15 cWhite, • насморк1
Gui, Add, Text, x120 y330 w70 h15 cWhite, • бессоница1
Gui, Add, Text, x120 y345 w70 h15 cWhite, • печень1
Gui, Add, Text, x120 y360 w70 h15 cWhite, • половые1
Gui, Add, Text, x120 y375 w70 h15 cWhite, • сердце1
Gui, Add, Text, x120 y390 w70 h15 cWhite, • зубы1
Gui, Add, Text, x120 y405 w70 h15 cWhite, • глаза1
Gui, Add, Text, x120 y420 w70 h15 cWhite, • ожог1
Gui, Add, Text, x120 y435 w70 h15 cWhite, • уши1
Gui, Add, Text, x120 y450 w70 h15 cWhite, • почки1
Gui, Add, Text, x120 y465 w70 h15 cWhite, • давление1
Gui, Add, Text, x120 y480 w70 h15 cWhite, • мочевой1
Gui, Add, Text, x120 y495 w70 h15 cWhite, • голова1

Gui 1:Font, s12 cWhite Bold, Gilroy
Gui, 1:Add, GroupBox, x237 y173 h500 w465 h155 c%Colors%, [ Причины для увольнения из «Ю» ( 9+ ) ]
Gui, 1:Font, S8 Cwhite Bold, Gilroy
Gui, 1:Add, Text, x247 y195 h20 w280 c%Colors%, Неактив
Gui, 1:Add, Text, x293 y195 h20 w280, - долгое отсутствие на рабочем месте
Gui, 1:Add, Text, x247 y210 h20 w280 c%Colors%, Нарушение ПДСФ/ФР
Gui, 1:Add, Text, x368 y210 h20 w222, - неоднократное нарушение дисциплины 
Gui, 1:Add, Text, x247 y225 h20 w280, или грубое нарушение дисциплины 
Gui, 1:Add, Text, x247 y240 h20 w280 c%Colors%, Нахождение в ОЧС
Gui, 1:Add, Text, x350 y240 h20 w232, - непригодность ко службе 
Gui, 1:Add, Text, x247 y255 h20 w280 c%Colors%, Снятие с лидерки
Gui, 1:Add, Text, x345 y255 h20 w232, - выслуга срока службы 
Gui, 1:Add, Text, x247 y270 h20 w280 c%Colors%, Нарушение IC документа
Gui, 1:Add, Text, x385 y270 h20 w200, - реализация дисциплинарного 
Gui, 1:Add, Text, x247 y285 h20 w180, взыскания в виде увольнения 
Gui, 1:Add, Text, x247 y300 h20 w280 c%Colors%, ПСЖ
Gui, 1:Add, Text, x275 y300 h20 w200, - по собственному желанию

Gui, 1:Font, S12 Cwhite Bold, Gilroy
Gui, 1:Add, GroupBox, x237 y322 w465 h90 c%Colors%, [ График выдачи мед.карт и проведения собес. ]
Gui, 1:Font, S8 Cwhite Bold, Gilroy
Gui, 1:Add, Text, x247 y345 h20 w280 c%Colors%, ЦГБ-П
Gui, 1:Add, Text, x282 y345 h20 w180, - Понедельник | Четверг
Gui, 1:Add, Text, x247 y360 h20 w280 c%Colors%, ОКБ-М
Gui, 1:Add, Text, x287 y360 h20 w180, - Вторник | Пятница
Gui, 1:Add, Text, x247 y375 h20 w280 c%Colors%, ЦГБ-Н
Gui, 1:Add, Text, x282 y375 h20 w180, - Среда | Суббота
Gui, 1:Add, Text, x247 y390 h20 w280 c%Colors%, Общий день
Gui, 1:Add, Text, x315 y390 h20 w180, - Воскресенье

Gui, 1:Font, S12 Cwhite Bold, Gilroy
Gui, 1:Add, GroupBox, x237 y407 w465 h60 c%Colors%, [ гор. клавиши ]
Gui, 1:Font, S8 Cwhite Bold, Gilroy
Gui, 1:Add, Text, x247 y430 h20 w280 c%Colors%, shift + f1
Gui, 1:Add, Text, x295 y430 h20 w180, - для перезапуска скрипта
Gui, 1:Add, Text, x247 y445 h20 w280 c%Colors%, shift + f2
Gui, 1:Add, Text, x295 y445 h20 w180, - для остановки скрипта

Gui 1:Font, s7 White Bold, Gilory
Gui, Add, Text, x620 y585 w999 h30 , by German_McKenzy
Gui, Add, Text, x5 y585 w111 h30 , v%currentversion%

;________________________________________________________________________________________________________________________________________________________________________________________

Gui, 1:Tab,2
Gui 1: Font, s12 cWhite Bold, Gilroy
Gui 1:Add, GroupBox, x10 y40 w340 h90 c%Colors%, [ соло ]
Gui 1:Font, s11 cWhite Bold, Gilroy
Gui, Add, Button, x580 y10 w120 h30 gData, settings
Gui, Add, Button, x435 y10 w140 h30 gUseLink, Полезные ссылки
Gui 1:Font, s8 White Bold, Gilory
Gui, Add, Text, x2 x20 y65 w222 h15 c%Colors%, • п1
Gui, Add, Text, x2 x39 y65 w222 h15 cwhite, — патруль города [ вертолет + карета ]
Gui, Add, Text, x2 x20 y80 w222 h15 c%Colors%, • прк1
Gui, Add, Text, x2 x52 y80 w150 h15 cwhite, — патруль респ. [ карета ]
Gui, Add, Text, x2 x20 y95 w200 h15 c%Colors%, • прв1
Gui, Add, Text, x2 x52 y95 w215 h15 cwhite, — патруль респ. [ вертолет ]
Gui, Add, Text, x2 x18 y135 w305 h15 cwhite, [ для дальнейших команд применяется следующий ввод ]
Gui, Add, Text, x2 x35 y153 w270 h15 c%Colors%, 1) выезд                 3) продолжение
Gui, Add, Text, x2 x35 y167 w187 h15 c%Colors%, 2) прибытие          4) завершение
Gui 1:Add, GroupBox, x10 y115 w340 h170
Gui, Add, Text, x2 x20 y200 w200 h15 c%Colors%, • пост1
Gui, Add, Text, x2 x59 y200 w215 h15 cwhite, — дежурство на посту КСМП
Gui, Add, Text, x2 x20 y215 w200 h15 c%Colors%, • постверт1
Gui, Add, Text, x2 x84 y215 w215 h15 cwhite, — дежурство на посту ВСМП
Gui, Add, Text, x2 x20 y230 w200 h15 c%Colors%, • дежсобес1
Gui, Add, Text, x2 x88 y230 w215 h15 cwhite, — дежурство на собеседовании организации
Gui, Add, Text, x2 x20 y245 w200 h15 c%Colors%, • дежувд1
Gui, Add, Text, x2 x74 y245 w215 h15 cwhite, — дежурство в УВД-М
Gui, Add, Text, x2 x20 y260 w200 h15 c%Colors%, • дежвч1
Gui, Add, Text, x2 x69 y260 w215 h15 cwhite, — дежурство на ВЧ

Gui, 1:Tab, 2
Gui 1: Font, s12 cWhite Bold, Gilroy
Gui 1:Add, GroupBox, x355 y40 w345 h90 c%Colors%, [ с напарником ]
Gui 1:Font, s8 White Bold, Gilory
Gui, Add, Text, x365 y65 w222 h15 c%Colors%, • пн1
Gui, Add, Text, x390 y65 w222 h15 cwhite, — патруль города [ вертолет + карета ]
Gui, Add, Text, x365 y80 w222 h15 c%Colors%, • пркн1
Gui, Add, Text, x405 y80 w150 h15 cwhite, — патруль респ. [ карета ]
Gui, Add, Text, x365 y95 w200 h15 c%Colors%, • првн1
Gui, Add, Text, x405 y95 w215 h15 cwhite, — патруль респ. [ вертолет ]
Gui, Add, Text, x363 y135 w305 h15 cwhite, [ для дальнейших команд применяется следующий ввод ]
Gui, Add, Text, x380 y153 w270 h15 c%Colors%, 1) выезд                 3) продолжение
Gui, Add, Text, x380 y167 w187 h15 c%Colors%, 2) прибытие          4) завершение
Gui 1:Add, GroupBox, x355 y115 w345 h170
Gui, Add, Text, x365 y200 w200 h15 c%Colors%, • постн1
Gui, Add, Text, x409 y200 w215 h15 cwhite, — дежурство на посту КСМП
Gui, Add, Text, x365 y215 w200 h15 c%Colors%, • поствертн1
Gui, Add, Text, x434 y215 w215 h15 cwhite, — дежурство на посту ВСМП
Gui, Add, Text, x365 y230 w200 h15 c%Colors%, • дежсобесн1
Gui, Add, Text, x438 y230 w215 h15 cwhite, — дежурство на собеседовании организации
Gui, Add, Text, x365 y245 w200 h15 c%Colors%, • дежувдн1
Gui, Add, Text, x424 y245 w215 h15 cwhite, — дежурство в УВД-М
Gui, Add, Text, x365 y260 w200 h15 c%Colors%, • дежвчн1
Gui, Add, Text, x419 y260 w215 h15 cwhite, — дежурство на ВЧ

Gui, 1:Tab, 2
Gui 1: Font, s12 cWhite Bold, Gilroy
Gui 1:Add, GroupBox, x10 y280 w690 h280 c%Colors%, [ нумерация постов ]
Gui 1:Font, s10 White Bold, Gilory
Gui, Add, Text, x140 y310 w520 h15 cwhite, Для стоянки на посту вам необходимо ввести номер поста в вкладу settings
Gui 1:Font, s8 White Bold, Gilory
Gui, Add, Text, x20 y345 w415 h15 cwhite, •
Gui, Add, Text, x20 y360 w415 h15 cwhite, •
Gui, Add, Text, x20 y375 w415 h15 cwhite, •
Gui, Add, Text, x20 y390 w415 h15 cwhite, •
Gui, Add, Text, x20 y405 w415 h15 cwhite, •
Gui, Add, Text, x20 y420 w415 h15 cwhite, •
Gui, Add, Text, x20 y435 w415 h15 cwhite, •
Gui, Add, Text, x20 y450 w415 h15 cwhite, •
Gui, Add, Text, x20 y465 w415 h15 cwhite, •
Gui, Add, Text, x20 y480 w415 h15 cwhite, •
Gui, Add, Text, x20 y495 w415 h15 cwhite, •
Gui, Add, Text, x20 y510 w415 h15 cwhite, •
Gui, Add, Text, x20 y525 w415 h15 cwhite, •
Gui, Add, Text, x20 y540 w415 h15 cwhite, •

Gui, Add, Text, x27 y345 w415 h15 c%Colors%, Пост №
Gui, Add, Text, x27 y360 w415 h15 c%Colors%, Пост №
Gui, Add, Text, x27 y375 w415 h15 c%Colors%, Пост №
Gui, Add, Text, x27 y390 w415 h15 c%Colors%, Пост №
Gui, Add, Text, x27 y405 w415 h15 c%Colors%, Пост №
Gui, Add, Text, x27 y420 w415 h15 c%Colors%, Пост №
Gui, Add, Text, x27 y435 w415 h15 c%Colors%, Пост №
Gui, Add, Text, x27 y450 w415 h15 c%Colors%, Пост №
Gui, Add, Text, x27 y465 w415 h15 c%Colors%, Пост №
Gui, Add, Text, x27 y480 w415 h15 c%Colors%, Пост №
Gui, Add, Text, x27 y495 w415 h15 c%Colors%, Пост №
Gui, Add, Text, x27 y510 w415 h15 c%Colors%, Пост №
Gui, Add, Text, x27 y525 w415 h15 c%Colors%, Пост №
Gui, Add, Text, x27 y540 w415 h15 c%Colors%, Пост №

Gui, Add, text, x68 y345 w415 h15 cwhite, 1 - Банк г. Мирный
Gui, Add, Text, x68 y360 w415 h15 cwhite, 2 - АТП г. Мирный
Gui, Add, Text, x68 y375 w415 h15 cwhite, 3 - Вокзал г. Мирный
Gui, Add, Text, x68 y390 w415 h15 cwhite, 4 - Речной вокзал г. Мирный
Gui, Add, Text, x68 y405 w415 h15 cwhite, 5 - Автосалон "МирБус"
Gui, Add, Text, x68 y420 w415 h15 cwhite, 6 - Троллейбусное депо г.Мирный
Gui, Add, Text, x68 y435 w415 h15 cwhite, 7 - Стройплощадка №1 г. Мирный
Gui, Add, Text, x68 y450 w415 h15 cwhite, 8 - Стройплощадка №2 г. Мирный
Gui, Add, Text, x68 y465 w415 h15 cwhite, 9 - Угольная шахта г. Мирный
Gui, Add, Text, x68 y480 w415 h15 cwhite, 10 - Офис ОАО "РЖД"
Gui, Add, Text, x68 y495 w415 h15 cwhite, 11 - Бар г. Мирный
Gui, Add, Text, x68 y510 w415 h15 cwhite, 12 - Судоходный шлюз
Gui, Add, Text, x68 y525 w415 h15 cwhite, 13 - Электродепо монорельса
Gui, Add, Text, x68 y540 w415 h15 cwhite, 14 - Деревня "Водино"
;--
Gui, Add, text, x168 y345 w115 h15 c%Colors% glink1, [ кликабельно ]
Gui, Add, Text, x164 y360 w115 c%Colors% glink2, [ кликабельно ]
Gui, Add, Text, x182 y375 w115 h15 c%Colors% glink3, [ кликабельно ]
Gui, Add, Text, x222 y390 w115 h15 c%Colors% glink4, [ кликабельно ]
Gui, Add, Text, x195 y405 w115 h15 c%Colors% glink5, [ кликабельно ]
Gui, Add, Text, x250 y420 w115 h15 c%Colors% glink6, [ кликабельно ]
Gui, Add, Text, x250 y435 w115 h15 c%Colors% glink7, [ кликабельно ]
Gui, Add, Text, x251 y450 w115 h15 c%Colors% glink8, [ кликабельно ]
Gui, Add, Text, x230 y465 w115 h15 c%Colors% glink9, [ кликабельно ]
Gui, Add, Text, x185 y480 w115 h15 c%Colors% glink10, [ кликабельно ]
Gui, Add, Text, x168 y495 w115 h15 c%Colors% glink11, [ кликабельно ]
Gui, Add, Text, x195 y510 w115 h15 c%Colors% glink12, [ кликабельно ]
Gui, Add, Text, x231 y525 w115 h15 c%Colors% glink13, [ кликабельно ]
Gui, Add, Text, x187 y540 w115 h15 c%Colors% glink14, [ кликабельно ]

Gui, Add, Text, x355 y345 w115 h15 cwhite, •
Gui, Add, Text, x355 y360 w115 h15 cwhite, •
Gui, Add, Text, x355 y375 w115 h15 cwhite, •
Gui, Add, Text, x355 y390 w115 h15 cwhite, •
Gui, Add, Text, x355 y405 w115 h15 cwhite, •

Gui, Add, Text, x362 y345 w215 h15 c%Colors%, Пост №
Gui, Add, Text, x362 y360 w215 h15 c%Colors%, Пост №
Gui, Add, Text, x362 y375 w215 h15 c%Colors%, Пост №
Gui, Add, Text, x362 y390 w215 h15 c%Colors%, Пост №
Gui, Add, Text, x362 y405 w215 h15 c%Colors%, Пост №

Gui, Add, text, x403 y345 w215 h15 cwhite, 15 - Деревня "Озерки"
Gui, Add, Text, x403 y360 w215 h15 cwhite, 16 - Заправка у ВЧ
Gui, Add, Text, x403 y375 w215 h15 cwhite, 17 - Лесопилка
Gui, Add, Text, x403 y390 w215 h15 cwhite, 18 - Спортзал
Gui, Add, Text, x403 y405 w215 h15 cwhite, 19 - Аэропорт

Gui, Add, text, x525 y345 w125 h15 c%Colors% glink15, [ кликабельно ]
Gui, Add, Text, x505 y360 w125 c%Colors% glink16, [ кликабельно ]
Gui, Add, Text, x483 y375 w150 h15 c%Colors% glink17, [ кликабельно ]
Gui, Add, Text, x480 y390 w150 h15 c%Colors% glink18, [ кликабельно ]
Gui, Add, Text, x480 y405 w150 h15 c%Colors% glink19, [ кликабельно ]
;==
Gui, 1:Font, S10  Cwhite Bold, Gilroy
Gui, Add, text, x468 y440 w125 h15 cwhite, Посты
Gui, Add, text, x509 y440 w125 h15 c%Colors%, ВСМП
Gui, 1:Font, S8  Cwhite Bold, Gilroy
Gui, Add, Text, x355 y460 w115 h15 cwhite, •
Gui, Add, Text, x355 y475 w115 h15 cwhite, •
Gui, Add, Text, x355 y490 w115 h15 cwhite, •
Gui, Add, Text, x355 y505 w115 h15 cwhite, •
Gui, Add, Text, x355 y520 w115 h15 cwhite, •
Gui, Add, Text, x355 y535 w115 h15 cwhite, •

Gui, Add, Text, x362 y460 w215 h15 c%Colors%, Пост №
Gui, Add, Text, x362 y475 w215 h15 c%Colors%, Пост №
Gui, Add, Text, x362 y490 w215 h15 c%Colors%, Пост №
Gui, Add, Text, x362 y505 w215 h15 c%Colors%, Пост №
Gui, Add, Text, x362 y520 w215 h15 c%Colors%, Пост №
Gui, Add, Text, x362 y535 w215 h15 c%Colors%, Пост №

Gui, Add, Text, x403 y460 w215 h15 cwhite, 1 - Судоходный шлюз
Gui, Add, Text, x403 y475 w215 h15 cwhite, 2 - Стадион г.Мирный
Gui, Add, Text, x403 y490 w215 h15 cwhite, 3 - Деревня Водино
Gui, Add, Text, x403 y505 w215 h15 cwhite, 4 - ТРК "СитиПаркГрад"
Gui, Add, Text, x403 y520 w215 h15 cwhite, 5 - Лесопилка
Gui, Add, Text, x403 y535 w215 h15 cwhite, 6 - ЖТУ пос. Жуковский

Gui, Add, text, x520 y460 w105 h15 c%Colors% glink1v, [ кликабельно ]
Gui, Add, Text, x520 y475 w105 c%Colors% glink2v, [ кликабельно ]
Gui, Add, Text, x510 y490 w100 h15 c%Colors% glink3v, [ кликабельно ]
Gui, Add, text, x530 y505 w100 h15 c%Colors% glink4v, [ кликабельно ]
Gui, Add, Text, x480 y520 w125 c%Colors% glink5v, [ кликабельно ]
Gui, Add, Text, x533 y535 w100 h15 c%Colors% glink6v, [ кликабельно ]

Gui 1:Add, GroupBox, x353 y448 w347 h112 c%Colors%

Gui 1:Font, s7 White Bold, Gilory
Gui, Add, Text, x620 y585 w999 h30 , by German_McKenzy
Gui, Add, Text, x5 y585 w111 h30 , v%currentversion%

;________________________________________________________________________________________________________________________________________________________________________________________

Gui, 1:Tab, 3
Gui 1: Font, s12 cWhite Bold, Gilroy
Gui 1:Add, GroupBox, x10 y40 w292 h395 c%Colors%, [ теоретические | 1 ]
Gui 1:Font, s11 cWhite Bold, Gilroy
Gui, Add, Button, x580 y10 w120 h30 gData, settings
Gui, Add, Button, x435 y10 w140 h30 gUseLink, Полезные ссылки
Gui 1:Font, s8 White Bold, Gilory
Gui, Add, Text, x2 x20 y65 w222 h15 cWhite, • лекдок
Gui, Add, Text, x2 x69 y65 w222 h15 c%Colors%, — уставные документы
Gui, Add, Text, x2 x20 y80 w222 h15 cWhite, • лексуб
Gui, Add, Text, x2 x66 y80 w150 h15 c%Colors%, — субординация
Gui, Add, Text, x2 x20 y95 w200 h15 cWhite, • лекрд
Gui, Add, Text, x2 x63 y95 w215 h15 c%Colors%, — рабочий день
Gui, Add, Text, x2 x20 y110 w200 h15 cWhite, • лекрация
Gui, Add, Text, x2 x79 y110 w215 h15 c%Colors%, — рации больницы
Gui, Add, Text, x2 x20 y125 w200 h15 cWhite, • лекксмп
Gui, Add, Text, x2 x72 y125 w215 h15 c%Colors%, — карета СМП
Gui, Add, Text, x2 x20 y140 w200 h15 cWhite, • лексобес
Gui, Add, Text, x2 x79 y140 w215 h15 c%Colors%, — дежурство на собеседованиях
Gui, Add, Text, x2 x20 y155 w200 h15 cWhite, • леккаш
Gui, Add, Text, x2 x71 y155 w215 h15 c%Colors%, — кашель
Gui, Add, Text, x2 x20 y170 w200 h15 cWhite, • лекорг
Gui, Add, Text, x2 x69 y170 w215 h15 c%Colors%, — организм
Gui, Add, Text, x2 x20 y185 w200 h15 cWhite, • лекскелет
Gui, Add, Text, x2 x82 y185 w215 h15 c%Colors%, — скелет человека
Gui, Add, Text, x2 x20 y200 w200 h15 cWhite, • леклей
Gui, Add, Text, x2 x67 y200 w215 h15 c%Colors%, — лейкоциты
Gui, Add, Text, x2 x20 y215 w200 h15 cWhite, • лексон
Gui, Add, Text, x2 x67 y215 w215 h15 c%Colors%, — сон
Gui, Add, Text, x2 x20 y230 w200 h15 cWhite, • лекпеч
Gui, Add, Text, x2 x67 y230 w215 h15 c%Colors%, — печень
Gui, Add, Text, x2 x20 y245 w200 h15 cWhite, • лекмаз
Gui, Add, Text, x2 x67 y245 w215 h15 c%Colors%, — появление мазолей
Gui, Add, Text, x2 x20 y260 w200 h15 cWhite, • леккамн
Gui, Add, Text, x2 x73 y260 w215 h15 c%Colors%, — появление камней в почках
Gui, Add, Text, x2 x20 y275 w200 h15 cWhite, • лекволос
Gui, Add, Text, x2 x79 y275 w215 h15 c%Colors%, — волосы на теле
Gui, Add, Text, x2 x20 y290 w200 h15 cWhite, • лекпатр
Gui, Add, Text, x2 x73 y290 w215 h15 c%Colors%, — патрулирование
Gui, Add, Text, x2 x20 y305 w200 h15 cWhite, • лекпост
Gui, Add, Text, x2 x74 y305 w215 h15 c%Colors%, — дежурство на посту
Gui, Add, Text, x2 x20 y320 w200 h15 cWhite, • лекверт
Gui, Add, Text, x2 x73 y320 w215 h15 c%Colors%, — мед. вертолет
Gui, Add, Text, x2 x20 y335 w200 h15 cWhite, • лекпуп
Gui, Add, Text, x2 x67 y335 w215 h15 c%Colors%, — пупок
Gui, Add, Text, x2 x20 y350 w200 h15 cWhite, • лекнар
Gui, Add, Text, x2 x67 y350 w215 h15 c%Colors%, — наркотики
Gui, Add, Text, x2 x20 y365 w200 h15 cWhite, • лексос
Gui, Add, Text, x2 x67 y365 w215 h15 c%Colors%, — кровеносные сосуды
Gui, Add, Text, x2 x20 y380 w200 h15 cWhite, • лексер
Gui, Add, Text, x2 x67 y380 w215 h15 c%Colors%, — сердце
Gui, Add, Text, x2 x20 y395 w200 h15 cWhite, • леквыз
Gui, Add, Text, x2 x67 y395 w215 h15 c%Colors%, — обработка вызова
Gui, Add, Text, x2 x20 y410 w200 h15 cWhite, • лекаллерг
Gui, Add, Text, x2 x84 y410 w215 h15 c%Colors%, — аллергия

Gui, 1:Tab, 3
Gui 1: Font, s12 cWhite Bold, Gilroy
Gui 1:Add, GroupBox, x10 y430 w292 h140 c%Colors%, [ практические ]
Gui 1:Font, s8 White Bold, Gilory
Gui, Add, Text, x2 x20 y455 w222 h15 c%Colors%, • лекпмпв
Gui, Add, Text, x2 x71 y455 w215 h15 cWhite, — пмп при вывихе
Gui, Add, Text, x2 x20 y470 w222 h15 c%Colors%, • лекпмппог
Gui, Add, Text, x2 x84 y470 w215 h15 cWhite, — пмп при огнестреле
Gui, Add, Text, x2 x20 y485 w222 h15 c%Colors%, • лекпмпоб
Gui, Add, Text, x2 x83 y485 w215 h15 cWhite, — пмп при обмороке
Gui, Add, Text, x2 x20 y500 w222 h15 c%Colors%, • лекпмппер
Gui, Add, Text, x2 x85 y500 w215 h15 cWhite, — пмп при переломе
Gui, Add, Text, x2 x20 y515 w222 h15 c%Colors%, • лекпмпож
Gui, Add, Text, x2 x83 y515 w215 h15 cWhite, — пмп при ожоге
Gui, Add, Text, x2 x20 y530 w222 h15 c%Colors%, • лекпмпкр
Gui, Add, Text, x2 x81 y530 w215 h15 cWhite, — пмп при кровотеч.
Gui, Add, Text, x2 x20 y545 w222 h15 c%Colors%, • лекпмпотр
Gui, Add, Text, x2 x83 y545 w215 h15 cWhite, — пмп при отравлении

Gui, 1:Tab, 3
Gui 1: Font, s12 cWhite Bold, Gilroy
Gui 1:Add, GroupBox, x305 y40 w395 h370 c%Colors%, [ теоретические | 2 ]
Gui 1:Font, s8 White Bold, Gilory
Gui, Add, Text, x2 x315 y65 w222 h15 cWhite, • лекчих
Gui, Add, Text, x2 x360 y65 w222 h15 c%Colors%, — причины чихания
Gui, Add, Text, x2 x315 y80 w222 h15 cWhite, • леккров
Gui, Add, Text, x2 x367 y80 w150 h15 c%Colors%, — кровь
Gui, Add, Text, x2 x315 y95 w200 h15 cWhite, • лекгол
Gui, Add, Text, x2 x360 y95 w215 h15 c%Colors%, — головная боль
Gui, Add, Text, x2 x315 y110 w200 h15 cWhite, • лекгли
Gui, Add, Text, x2 x360 y110 w215 h15 c%Colors%, — причины появ. глистов
Gui, Add, Text, x2 x315 y125 w200 h15 cWhite, • леквес
Gui, Add, Text, x2 x360 y125 w215 h15 c%Colors%, — появ. веснушек
Gui, Add, Text, x2 x315 y140 w200 h15 cWhite, • леккур
Gui, Add, Text, x2 x364 y140 w215 h15 c%Colors%, — курение
Gui, Add, Text, x2 x315 y155 w200 h15 cWhite, • лексах
Gui, Add, Text, x2 x360 y155 w215 h15 c%Colors%, — сахарный диабет
Gui, Add, Text, x2 x315 y170 w200 h15 cWhite, • лекдиар
Gui, Add, Text, x2 x368 y170 w215 h15 c%Colors%, — диарея
Gui, Add, Text, x2 x315 y185 w200 h15 cWhite, • леккар
Gui, Add, Text, x2 x365 y185 w215 h15 c%Colors%, — кариес
Gui, Add, Text, x2 x315 y200 w200 h15 cWhite, • лекбег
Gui, Add, Text, x2 x358 y200 w215 h15 c%Colors%, — бег
Gui, Add, Text, x2 x315 y215 w200 h15 cWhite, • лекинф
Gui, Add, Text, x2 x364 y215 w215 h15 c%Colors%, — инфаркт
Gui, Add, Text, x2 x315 y230 w200 h15 cWhite, • лекинс
Gui, Add, Text, x2 x360 y230 w215 h15 c%Colors%, — инсульт
Gui, Add, Text, x2 x315 y245 w200 h15 cWhite, • лекзап
Gui, Add, Text, x2 x360 y245 w215 h15 c%Colors%, — запор
Gui, Add, Text, x2 x315 y260 w200 h15 cWhite, • лекперелом
Gui, Add, Text, x2 x387 y260 w200 h15 c%Colors%, — перелом пальцев
Gui, Add, Text, x2 x315 y275 w200 h15 cWhite, • лекрод
Gui, Add, Text, x2 x365 y275 w215 h15 c%Colors%, — появ. родинок
Gui, Add, Text, x2 x315 y290 w200 h15 cWhite, • лекног
Gui, Add, Text, x2 x360 y290 w215 h15 c%Colors%, — ногти
Gui, Add, Text, x2 x315 y305 w200 h15 cWhite, • леклег
Gui, Add, Text, x2 x358 y305 w215 h15 c%Colors%, — легкие
Gui, Add, Text, x2 x315 y320 w200 h15 cWhite, • леквита
Gui, Add, Text, x2 x367 y320 w215 h15 c%Colors%, — витамины
Gui, Add, Text, x2 x315 y335 w200 h15 cWhite, • лекалек
Gui, Add, Text, x2 x367 y335 w215 h15 c%Colors%, — алексия
Gui, Add, Text, x2 x315 y350 w200 h15 cWhite, • лекдиаб
Gui, Add, Text, x2 x369 y350 w215 h15 c%Colors%, — диабет
Gui, Add, Text, x2 x315 y365 w200 h15 cWhite, • леккат
Gui, Add, Text, x2 x360 y365 w215 h15 c%Colors%, — катаракта
Gui, Add, Text, x2 x315 y380 w185 h15 cWhite, • лекосткров
Gui, Add, Text, x2 x387 y380 w185 h15 c%Colors%, — остановка крови

Gui, 1:Tab, 3
Gui 1: Font, s12 cWhite Bold, Gilroy
Gui 1:Add, GroupBox, x305 y405 w395 h50 c%Colors%, [ other ]
Gui 1:Font, s8 White Bold, Gilory
Gui, Add, Text, x2 x315 y430 w222 h15 cWhite, • леквст
Gui, Add, Text, x2 x360 y430 w222 h15 c%Colors%, — вступительная

Gui 1:Font, s7 White Bold, Gilory
Gui, Add, Text, x620 y585 w999 h30 , by German_McKenzy
Gui, Add, Text, x5 y585 w111 h30 , v%currentversion%
;________________________________________________________________________________________________________________________________________________________________________________________
Gui, 1:Tab, 4
Gui 1: Font, s12 cWhite Bold, Gilroy
Gui 1:Add, GroupBox, x10 y40 w410 h462 c%Colors%, [ общие критерии ( 2 - 10 ранги ) ]
Gui 1:Font, s11 cWhite Bold, Gilroy
Gui, Add, Button, x580 y10 w120 h30 gData, settings
Gui, Add, Button, x435 y10 w140 h30 gUseLink, Полезные ссылки
Gui 1:Font, s8 White Bold, Gilory
Gui, Add, Text, x2 x20 y65 w350 h15 cWhite, • Дежурство на собеседованиях в другие организации [10 мин]
Gui, Add, Text, x2 x360 y65 w55 h15 c%Colors%, — 2 балла
Gui, Add, Text, x2 x20 y80 w292 h15 cWhite, • Дежурство в здании УВД в течение 10 минут
Gui, Add, Text, x2 x263 y80 w61 h15 c%Colors%, — 2 балла
Gui, Add, Text, x2 x20 y95 w292 h15 cWhite, • Дежурство на территории ВЧ в течение 10 минут
Gui, Add, Text, x2 x288 y95 w61 h15 c%Colors%, — 2 балла
Gui, Add, Text, x2 x20 y110 w292 h15 cWhite, • Лечение пациента
Gui, Add, Text, x2 x125 y110 w61 h15 c%Colors%, — 1 балл
Gui, Add, Text, x20 y125 w292 h20 cWhite, • Обработка вызова с последующей госпитализацией
Gui, Add, Text, x312 y125 w61 h20 c%Colors%, — 3 балла*
Gui, Add, Text, x20 y140 w292 h20 cWhite, • Обработка ложного вызова
Gui, Add, Text, x180 y140 w61 h20 c%Colors%, — 1,5 балла*
Gui, Add, Text, x20 y155 w292 h20 cWhite, • Обработка отмененного вызова
Gui, Add, Text, x202 y155 w61 h20 c%Colors%, — 0,5 балла*
Gui, Add, Text, x20 y170 w292 h20 cWhite, • Проведение мед. освидетельствования
Gui, Add, Text, x237 y170 w61 h20 c%Colors%, — 2 балла
Gui, Add, Text, x20 y185 w292 h20 cWhite, • Патрулирование в течение 10 минут на карете СМП
Gui, Add, Text, x300 y185 w61 h20 c%Colors%, — 2 балла
Gui, Add, Text, x20 y200 w310 h20 cWhite, • Патрулирование в течение 10 минут на вертолете СМП
Gui, Add, Text, x317 y200 w61 h20 c%Colors%, — 2 балла
Gui, Add, Text, x20 y215 w350 h20 cWhite, • Проведение мед.осмотра для получения мед.карты (с 5 ранга)
Gui, Add, Text, x362 y215 w50 h20 c%Colors%, — 1 балл
Gui, Add, Text, x20 y230 w360 h20 cWhite, • Проведение мед.осмотра для получ. медкарты [масс.]
Gui, Add, Text, x318 y230 w61 h20 c%Colors%, — 2 балла
Gui, Add, Text, x20 y245 w292 h20 cWhite, • Выдача медицинской карты
Gui, Add, Text, x180 y245 w61 h20 c%Colors%, — 3 балла*
Gui, Add, Text, x20 y260 w350 h20 cWhite, • Выдача медицинской карты в ходе коллективной заявки
Gui, Add, Text, x335 y260 w69 h20 c%Colors%, — 5 баллов*
Gui, Add, Text, x20 y275 w380 h20 cWhite, • Проведение мед.осмотра для получ. мед. карты по эл. заявке
Gui, Add, Text, x360 y275 w55 h20 c%Colors%, — 2 балла
Gui, Add, Text, x20 y290 w292 h20 cWhite, • Выдача медицинской карты по электронной заявке
Gui, Add, Text, x307 y290 w61 h20 c%Colors%, — 4 балла
Gui, Add, Text, x20 y305 w292 h20 cWhite, • Проведение операции
Gui, Add, Text, x150 y305 w61 h20 c%Colors%, — 4 балла*
Gui, Add, Text, x20 y320 w292 h20 cWhite, • Стоянка на посту в течение 10 минут на карете СМП
Gui, Add, Text, x307 y320 w61 h20 c%Colors%, — 2 балла
Gui, Add, Text, x20 y335 w333 h20 cWhite, • Стоянка на посту в течение 10 минут на вертолете СМП
Gui, Add, Text, x322 y335 w61 h20 c%Colors%, — 2 балла
Gui, Add, Text, x20 y350 w292 h20 cWhite, • Помощь в проведении собеседования (с 5 ранга)
Gui, Add, Text, x290 y350 w61 h20 c%Colors%, — 4 балла
Gui, Add, Text, x20 y365 w360 h20 cWhite, • Прохождение одной контр.точки в ходе маршрут. патрул.
Gui, Add, Text, x335 y365 w61 h20 c%Colors%, — 2,5 балла
Gui, Add, Text, x20 y380 w292 h20 cWhite, • Прослушивание практической лекции
Gui, Add, Text, x233 y380 w61 h20 c%Colors%, — 2 балла
Gui, Add, Text, x20 y395 w292 h20 cWhite, • Прослушивание теоретической лекции
Gui, Add, Text, x237 y395 w61 h20 c%Colors%, — 1 балл
Gui, Add, Text, x20 y410 w350 h20 cWhite, • Участие в развлекательном мероприятии для фракции
Gui, Add, Text, x320 y410 w61 h20 c%Colors%, — 1 балл
Gui, Add, Text, x20 y425 w292 h20 cWhite, • Участие в Role Play мероприятии для фракции
Gui, Add, Text, x275 y425 w61 h20 c%Colors%, — 3 балла
Gui, Add, Text, x20 y440 w350 h20 cWhite, • Участие в Role Play мероприятии совместно с др. орг.
Gui, Add, Text, x317 y440 w61 h20 c%Colors%, — 4 балла*
Gui, Add, Text, x20 y455 w360 h20 cWhite, • Участие в Role Play мероприятии с привлечением гр. лиц
Gui, Add, Text, x330 y455 w61 h20 c%Colors%, — 5 баллов*
Gui, Add, Text, x20 y470 w360 h20 cWhite, • Участие в глобальном мероприятии в качестве сотрудника
Gui, Add, Text, x345 y470 w64 h20 c%Colors%, — 6 баллов*


Gui 1: Font, s12 cWhite Bold, Gilroy
Gui 1:Add, GroupBox, x425 y40 w280 h210 c%Colors%, [ Критерии для ВВК ( 7-10 ) ]
Gui 1:Font, s8 White Bold, Gilory
Gui, Add, Text, x435 y65 w202 h15 cWhite, • Провед. вступ.лекции для интернов
Gui, Add, Text, x633 y65 w55 h15 c%Colors%, — 2 балла
Gui, Add, Text, x435 y80 w202 h15 cWhite, • Проведение личного собесед.
Gui, Add, Text, x602 y80 w55 h15 c%Colors%, — 4 балла
Gui, Add, Text, x435 y95 w202 h15 cWhite, • Проведение очного собесед.
Gui, Add, Text, x597 y95 w55 h15 c%Colors%, — 5 балла
Gui, Add, Text, x435 y110 w202 h15 cWhite, • Проведение практич. лекции
Gui, Add, Text, x598 y110 w55 h15 c%Colors%, — 3 балла
Gui, Add, Text, x435 y125 w242 h15 cWhite, • Проведение развлекат. МП для фрак.
Gui, Add, Text, x643 y125 w55 h15 c%Colors%, — 2 балла
Gui, Add, Text, x435 y140 w202 h15 cWhite, • Проведение теоретич. лекции
Gui, Add, Text, x602 y140 w55 h15 c%Colors%, — 2 балла
Gui, Add, Text, x435 y155 w242 h15 cWhite, • Проведение RP МП для фрак.
Gui, Add, Text, x597 y155 w55 h15 c%Colors%, — 4 балла
Gui, Add, Text, x435 y170 w242 h15 cWhite, • Проведение RP МП с другими орг.
Gui, Add, Text, x625 y170 w61 h15 c%Colors%, — 5 баллов
Gui, Add, Text, x435 y185 w242 h15 cWhite, • Проведение RP МП с привлеч. гр. лиц
Gui, Add, Text, x640 y185 w61 h15 c%Colors%, — 8 баллов
Gui, Add, Text, x435 y200 w242 h15 cWhite, • Проверка отчетов сотрудников МС
Gui, Add, Text, x635 y200 w55 h15 c%Colors%, — 2 балла
Gui, Add, Text, x435 y215 w242 h15 cWhite, • Публикация поста в группу МЗ
Gui, Add, Text, x607 y215 w63 h15 c%Colors%, — 12 баллов
Gui, Add, Text, x435 y230 w202 h15 cWhite, • Проведение ГМП
Gui, Add, Text, x533 y230 w63 h15 c%Colors%, — 12 баллов

Gui 1: Font, s12 cWhite Bold, Gilroy
Gui 1:Add, GroupBox, x425 y245 w280 h75 c%Colors%, [ Критерии для ГМИ ]
Gui 1:Font, s8 White Bold, Gilory
Gui, Add, Text, x435 y270 w202 h15 cWhite, • Качественное принятия зачета
Gui, Add, Text, x607 y270 w61 h15 c%Colors%, — 2 балла
Gui, Add, Text, x435 y285 w202 h15 cWhite, • Качественная проверка экзамена
Gui, Add, Text, x624 y285 w61 h15 c%Colors%, — 4 балла
Gui, Add, Text, x435 y300 w202 h15 cWhite, • Проведение производ. практики
Gui, Add, Text, x617 y300 w61 h15 c%Colors%, — 4,5 балла

Gui 1: Font, s12 cWhite Bold, Gilroy
Gui 1:Add, GroupBox, x425 y315 w280 h105 c%Colors%, [ Баллы для повышения ]
Gui 1:Font, s7 White Bold, Gilory
Gui, Add, Text, x435 y340 w202 h15 cWhite, • Интерн ->
Gui, Add, Text, x485 y340 w202 h15 c%Colors%, Фельдшер
Gui, Add, Text, x530 y340 w150 h15 cwhite, — получение мед. диплома (ГМИ);
Gui, Add, Text, x435 y355 w202 h15 cWhite, • Фельдшер ->
Gui, Add, Text, x498 y355 w202 h15 c%Colors%, Лаборант
Gui, Add, Text, x543 y355 w150 h15 cwhite, — набрать 30 баллов;
Gui, Add, Text, x435 y370 w202 h15 cWhite, • Лаборант ->
Gui, Add, Text, x498 y370 w202 h15 c%Colors%, Врач-стажёр
Gui, Add, Text, x560 y370 w120 h15 cwhite, — набрать 50 баллов;
Gui, Add, Text, x435 y385 w202 h15 cWhite, • Врач-стажёр ->
Gui, Add, Text, x514 y385 w150 h15 c%Colors%, Врач-участковый
Gui, Add, Text, x595 y385 w93 h15 cwhite, — набрать 70 баллов;
Gui, Add, Text, x435 y400 w202 h15 cWhite, • Врач-участковый ->
Gui, Add, Text, x532 y400 w150 h15 c%Colors%, Врач-терапевт
Gui, Add, Text, x600 y400 w94 h15 cwhite, — набрать 90 баллов;

Gui 1: Font, s12 cWhite Bold, Gilroy
Gui 1:Add, GroupBox, x425 y415 w280 h87 c%Colors%, [ Еженедельный отчет ]
Gui 1:Font, s7 White Bold, Gilory
Gui, Add, Text, x435 y440 w202 h15 c%Colors%, • Врач-терапевт
Gui, Add, Text, x510 y440 w102 h15 cWhite, —  набрать 70 баллов;
Gui, Add, Text, x435 y455 w202 h15 c%Colors%, • Врач-хирург
Gui, Add, Text, x500 y455 w102 h15 cWhite, —  набрать 95 баллов;
Gui, Add, Text, x435 y470 w202 h15 c%Colors%, • Заведующий отделением
Gui, Add, Text, x549 y470 w102 h15 cWhite, —  набрать 100 баллов;
Gui, Add, Text, x435 y485 w202 h15 c%Colors%, • Заместители главного врача
Gui, Add, Text, x568 y485 w102 h15 cWhite, —  набрать 105 баллов;

Gui 1: Font, s12 cWhite Bold, Gilroy
Gui 1:Add, GroupBox, x10 y495 w348 h70
Gui 1:Add, GroupBox, x10 y495 w696 h70 c%Colors%, [ Снятие ДВ ]
Gui 1:Font, s10 cWhite Bold, Gilroy
Gui, Add, Text, x130 y509 w102 h15 c%Colors%, Младший
Gui, Add, Text, x193 y509 w102 h15 cwhite, состав
Gui, Add, Text, x480 y509 w102 h15 c%Colors%, Старший
Gui, Add, Text, x540 y509 w102 h15 cwhite, состав
Gui 1:Font, s7 cWhite Bold, Gilroy
Gui, Add, Text, x20 y525 w102 h15 c%Colors%, Предупреждение
Gui, Add, Text, x93 y525 w102 h15 cwhite, —  набрать 40 баллов;
Gui, Add, Text, x20 y535 w102 h15 c%Colors%, Выговор
Gui, Add, Text, x60 y535 w102 h15 cwhite, —  набрать 50 баллов;
Gui, Add, Text, x20 y545 w142 h15 c%Colors%, Строгий выговор
Gui, Add, Text, x107 y545 w102 h15 cwhite, —  набрать 75 баллов;

Gui, Add, Text, x370 y525 w102 h15 c%Colors%, Предупреждение
Gui, Add, Text, x443 y525 w102 h15 cwhite, —  набрать 55 баллов;
Gui, Add, Text, x370 y535 w102 h15 c%Colors%, Выговор
Gui, Add, Text, x410 y535 w102 h15 cwhite, —  набрать 70 баллов;
Gui, Add, Text, x370 y545 w142 h15 c%Colors%, Строгий выговор
Gui, Add, Text, x457 y545 w102 h15 cwhite, —  набрать 90 баллов;

Gui 1:Font, s7 White Bold, Gilory
Gui, Add, Text, x620 y585 w999 h30 , by German_McKenzy
Gui, Add, Text, x5 y585 w111 h30 , v%currentversion%

;________________________________________________________________________________________________________________________________________________________________________________________
Gui, 1:Tab, 5
Gui 1: Font, s12 cWhite Bold, Gilroy
Gui 1:Add, text, x210 y50 w410 h30 c%Colors%, [ Правила фиксации рабочего времени ]
Gui 1:Font, s11 cWhite Bold, Gilroy
Gui, Add, Button, x580 y10 w120 h30 gData, settings
Gui, Add, Button, x435 y10 w140 h30 gUseLink, Полезные ссылки
Gui 1:Font, s8 White Bold, Gilory
Gui, Add, Text, x20 y85 w350 h15 c%Colors%,  1) RP лечение пациента
Gui, Add, Text, x40 y100 w350 h15 cwhite,  • Наличие отыгровки от пациента о взятии препарата
Gui, Add, Text, x40 y115 w350 h15 cwhite,  • Системное уведомление о согласии на лечение
Gui, Add, Text, x20 y130 w350 h15 c%Colors%,  2) Хирургические вмешательства (операции)
Gui, Add, Text, x40 y145 w555 h15 cwhite,  • Скриншоты проведения операционных действий (как минимум 2 скриншота ситуации)
Gui, Add, Text, x20 y160 w350 h15 c%Colors%,  3) Выезд на вызов (любой категории)
Gui, Add, Text, x40 y175 w555 h15 cwhite,  • Доклад о принятии вызова
Gui, Add, Text, x40 y190 w555 h15 cwhite,  • Доклад об обработке вызова (при обработке на месте)
Gui, Add, Text, x40 y205 w555 h15 cwhite,  • В случае госпитализации пациента, на скриншоте должно присутствовать системное уведомление
Gui, Add, Text, x20 y220 w350 h15 c%Colors%,  4) Мобильные посты города/вертолетные посты
Gui, Add, Text, x40 y235 w555 h15 cwhite,  • Доклад о выезде/вылете на пост
Gui, Add, Text, x40 y250 w555 h15 cwhite,  • Доклад о прибытии на место поста
Gui, Add, Text, x40 y265 w555 h15 cwhite,  • Доклад о продолжении стоянки (каждые 10 минут)
Gui, Add, Text, x40 y280 w555 h15 cwhite,  • Доклад о завершении стоянки на посту
Gui, Add, Text, x20 y295 w350 h15 c%Colors%,  5) Автомобильные патрули города или Республики/воздушные патрули города или республики
Gui, Add, Text, x40 y310 w555 h15 cwhite,  • Доклад о начале патруля
Gui, Add, Text, x40 y325 w555 h15 cwhite,  • Доклад о продолжении патруля (каждые 10 минут)
Gui, Add, Text, x40 y340 w555 h15 cwhite,  • Доклад о завершении патруля
Gui, Add, Text, x20 y355 w350 h15 c%Colors%,  6) Дежурства в здании УВД
Gui, Add, Text, x40 y370 w555 h15 cwhite,  • Доклад о выезде на дежурство
Gui, Add, Text, x40 y385 w555 h15 cwhite,  • Доклад о заступлении в дежурство
Gui, Add, Text, x40 y400 w555 h15 cwhite,  • Доклад о продолжении дежурства (каждые 10 минут)
Gui, Add, Text, x40 y415 w555 h15 cwhite,  • Доклад о завершении дежурства
Gui, Add, Text, x20 y430 w350 h15 c%Colors%,  7) Прослушивание лекции
Gui, Add, Text, x40 y445 w555 h15 cwhite,  • Скриншот начала и конца лекции
Gui, Add, Text, x20 y460 w350 h15 c%Colors%,  8) Участие в мероприятии от старшего состава
Gui, Add, Text, x40 y475 w555 h15 cwhite,  • Скришот о начале и конце мероприятия
Gui, Add, Text, x40 y490 w555 h15 cwhite,  • Как минимум 1 любой скриншот ситуации с мероприятия
Gui, Add, Text, x20 y505 w350 h15 c%Colors%,  9) Участие в глобальном мероприятии
Gui, Add, Text, x40 y520 w555 h15 cwhite,  • Как минимум 3 скришота ситуации с мероприятия
Gui, Add, Text, x20 y535 w350 h15 c%Colors%,  10) Выдача медицинской карты
Gui, Add, Text, x40 y550 w555 h15 cwhite,  • Скриншот начала проведения осмотра
Gui, Add, Text, x40 y565 w555 h15 cwhite,  • Скриншот о постановке печати
Gui, Add, Text, x40 y580 w555 h15 cwhite,  • Системное уведомление о согласии пациента на приобретение карты
Gui, Add, Text, x420 y535 w350 h15 c%Colors%,  11) Дежурство на собеседованиях у других орг.
Gui, Add, Text, x440 y550 w555 h15 cwhite,  • Скриншоты в хх:20, хх:30, хх:40, хх:50

;________________________________________________________________________________________________________________________________________________________________________________________

LoadData()
{
    global Tag, Partners, City, Post, Frac, iniFile , FIO , Ran , Disc , Colors
    if (FileExist(iniFile))
    {
        FileRead, FileContent, %iniFile%
        Loop, Parse, FileContent, `n, `r
        {
            StringSplit, LineArray, A_LoopField, `:
            Var := Trim(LineArray1)
            Value := Trim(LineArray2)
            if (Var = "Tag")
                Tag := Value
            else if (Var = "Partners")
                Partners := Value
            else if (Var = "City")
                City := Value
            else if (Var = "Post")
                Post := Value
            else if (Var = "Frac")
                Frac := Value
            else if (Var = "FIO")
                FIO := Value
            else if (Var = "Rang")
                Rang := Value
            else if (Var = "Disc")
                Disc := Value
            else if (Var = "Colors")
                Colors := Value
        }
    }
    if (Colors = "")
        Colors := "FD7B7C"
}

;________________________________________________________________________________________________________________________________________________________________________________________

LoadData()

+f1::
reload

GuiClose:
ExitApp

+f2::
Pause

Global City := "ЦГБ-П|ОКБ-М|ЦГБ-Н"

IniRead(Section, Key, Default = "") {
  IniRead, OutputVar, %iniFile%, %Section%, %Key%, %Default%
  return OutputVar
}

SetIniValue(Key, Value) {
    IniWrite, %Value%, %iniFile%, %Section%, %Key%
}

Data:
Gui, NewWindow: New, , data
Gui, Color, 202127 
Gui, Show, center w610 h512
Gui, Font, S13  Cwhite Bold, Gilroy
Gui, Add, Text, x10 y10 w300 h20 c%Colors%, [ Данные сотрудника ]
Gui, Font, S10  Cwhite Bold, Gilroy

;Gui, Add, DropDownList, x435 y10 w160 h220 cblack vCity, %City%
Gui, Add, text, x330 y10 w160 h20, Город работы:
Gui, Add, edit, x435 y10 w160 h20 cblack vCity, %City%

Gui, Font, S9  Cwhite Bold, Gilroy
Gui, Add, Text, x15 y40 w250 h20, ФИО | *МаКензи Герман Викторович*
Gui, Add, Edit, x15 y60 w260 h20 cblack vFIO, %FIO%

Gui, Add, Text, x285 y40 w300 h20, Занимаемая должность | *Врач-терапевт*
;Gui, Add, DropDownList, x285 y60 w200 h420 cblack vRang , Интерн|Фельдшер|Лаборант|Врач-стажер|Врач-участковый|Врач-терапевт|Врач-хирург|Заведующий отделением|Заместитель ГВ|Главный врач
Gui, Add, edit, x285 y60 w200 h20 cblack vRang , %Rang%

Gui, Add, Text, x15 y100 w160 h20, Используемый тег | *ОРИТ*
Gui, Add, Edit, x15 y120 w165 h20 cblack vTag, %Tag%

Gui, Add, Text, x190 y100 w400 h20, Введите Имя Фамилию напарника для докладов | *Ренат МаКензи*
Gui, Add, Edit, x190 y120 w400 h20 cblack vPartners, %Partners%

Gui, Add, Text, x375 y160 w450 h20, Введите номер поста (к примеру: 1)
Gui, Add, Edit, x375 y180 w220 h20 cblack vPost, %Post%

Gui, Add, Text, x15 y160 w350 h20, Введите название фракции, на которой вы дежурите
;Gui, Add, DropDownList, x15 y180 w350 h220 cblack vFrac, РЖД|МО|УВД-П|УВД-М|УВД-Н|ГИБДД-П|ГИБДД-М|ГИБДД-Н
Gui, Add, edit, x15 y180 w350 h20 cblack vFrac, %Frac%

Gui, Add, Text, x15 y220 w200 h20, Пол персонажа: [ не работает ]
Gui, Add, Radio, x15 y240 w100 h17 cwhite, Мужской
Gui, Add, Radio, x115 y240 w100 h17 cwhite, Женский

GUI, add, groupbox, x-10 y-10 w999 h300
Gui, Add, Button, x15 y450 w200 h30 gSaveData, Сохранить
;Gui, Add, Button, x222 y270 w200 h30 gReset, Сбросить

Gui, add, text, x15 y300 w700 h20, Укажите диск, на котором установлена MTA Province: C/D/E...
Gui, Add, edit, x15 y315 w20 h20 r1 vDisc cblack limit1, %Disc%

Gui, add, text, x15 y340 w700 h20, Введите HEX-код для изменения цвета интерфейса
Gui, Add, edit, x15 y355 w80 h20 r1 vColors cblack limit6, %Colors%

Gui Font, s7 White Bold, Gilory
Gui, Add, Text, x520 y500 w999 h30 , by German_McKenzy
Gui, Add, Text, x5 y500 w111 h30, v%currentversion%

    Gui, NewWindow:Show, , mz.ahk by mck
return
;________________________________________________________________________________________________________________________________________________________________________________________

rungame:
    If (Disc = "")
    {
        MsgBox, 16, Ошибка, Пожалуйста, выберите диск.
        Return
    }

    GameExe := Disc ":\Province Games\Multi Theft Auto.exe"
 ;GameExe := ProvPath "\Multi Theft Auto.exe"

    If (!FileExist(GameExe))
    {
        MsgBox, 16, Ошибка, Не найден исполняемый файл "%GameExe%".  Проверьте правильность выбранного диска.
        Return
    }

 Run, "%GameExe%" mtasa://%ServerAddress%, UseErrorLevelу

    If ErrorLevel
    {
        MsgBox, 16, Ошибка запуска, Не удалось запустить игру. Код ошибки: %ErrorLevel%
    }
Return

SaveData:
    Gui, Submit, NoHide
    FileDelete, %iniFile%
    FileAppend, 
    (
        Tag: %Tag%`n
        Partners: %Partners%`n
        City: %City%`n
        Post: %Post%`n
        Frac: %Frac%`n
        FIO: %FIO%`n  
        Rang: %Rang%`n  
        Disc: %Disc%`n  
        Colors: %Colors%`n  
    ), %iniFile%
    MsgBox, 64, Сохранено, Данные успешно сохранены в файл: %iniFile% .
Return

killgame:
WinKill, MTA: San Andreas
return
;________________________________________________________________________________________________________________________________________________________________________________________

link1:
run, https://imgur.com/a/yrhyK1e
return

link2:
run, https://imgur.com/a/yUPdKGm
return

link3:
run, https://imgur.com/a/Q1NI0sP
return

link4:
run, https://imgur.com/a/Mvdlysa
return

link5:
run, https://imgur.com/a/g7u2aMm
return

link6:
run, https://imgur.com/a/3rwBkwE
return

link7:
run, https://imgur.com/a/Vbn8AkK
return

link8:
run, https://imgur.com/a/ce34qL2
return

link9:
run, https://imgur.com/a/ePRoyh5
return

link10:
run, https://imgur.com/a/6CAN4PF
return

link11:
run, https://imgur.com/a/zN6TISS
return

link12:
run, https://imgur.com/a/7vyW37p
return

link13:
run, https://imgur.com/a/lghlgbZ
return

link14:
run, https://imgur.com/a/rqMSNtC
return

link15:
run, https://imgur.com/a/fvwJIy1
return

link16:
run, https://imgur.com/a/J0jebPr
return

link17:
run, https://imgur.com/a/K47530O
return

link18:
run, https://imgur.com/a/UNmEmAT
return

link19:
run, https://imgur.com/a/WSj6VB0
return

link1v:
run, https://imgur.com/a/EperMUP
return

link2v:
run, https://imgur.com/a/jsRWS68
return

link3v:
run, https://imgur.com/a/vle6MIW
return

link4v:
run, https://imgur.com/a/pMwoyCB
return

link5v:
run, https://imgur.com/a/EoV2jxl
return

link6v:
run, https://imgur.com/a/Oqp4vLV
return

;________________________________________________________________________________________________________________________________________________________________________________________

UseLink:
Gui, NewWindow: New, , Полезные ссылки
Gui, Color, 202127 
Gui, Show, center w415 h400
Gui, Font, S14  Cwhite Bold, Gilroy
Gui, Add, Text, x33 y8 w555 h24, [ Кнопки ведут на вкладки в браузере ]
Gui, Font, S12  Cwhite Bold, Gilroy
Gui, Add, groupbox, x5 y40 w200 h220 c%Colors%, [ МинЗдрав ]
Gui, Font, S10  Cwhite Bold, Gilroy
Gui, Add, Button, x13 y70 w185 h20 gmzforum, МЗ [ общее ]
Gui, Add, Button, x13 y95 w185 h20 gpomz, ПоМЗ [ документ ]
Gui, Add, Button, x13 y120 w185 h20 ginfo, ИнфоРаздел [ FAQ ]
Gui, Add, Button, x13 y145 w185 h20 grosmp, РОСМП [ документ ]
Gui, Add, Button, x13 y170 w185 h20 gballsys, Балльная система [ INFO ]
Gui, Add, Button, x13 y195 w185 h20 gmzvk, Группа МЗ в VK [ NEWS ]
Gui, Add, Button, x13 y220 w185 h20 gcalk, Калькулятор баллов [ RES ]

Gui, Font, S12  Cwhite Bold, Gilroy
Gui, Add, groupbox, x210 y40 w200 h220 c%Colors%, [ Обще-фракцион. ]
Gui, Font, S10  Cwhite Bold, Gilroy
Gui, Add, Button, x218 y70 w185 h20 gpdsf, ПдСФ [ документ ]
Gui, Add, Button, x218 y95 w185 h20 gpdfr, ПдФР [ документ для 7-10 ]
Gui, Add, Button, x218 y120 w185 h20 gcalend, График работы [ календарь ]
Gui, Add, Button, x218 y145 w185 h20 gperevod, Правила переводов [ FAQ ]
Gui, Add, Button, x218 y170 w185 h20 gochs, ОЧС [ INFO ]
Gui, Add, Button, x218 y195 w185 h20 gnovost, Новости фрак. [ NEWS ]

Gui, Font, S12  Cwhite Bold, Gilroy
Gui, Add, groupbox, x5 y255 w405 h85 c%Colors%, [ mz.ahk ]
Gui, Font, S10  Cwhite Bold, Gilroy
Gui, Add, Button, x13 y285 w390 h20 gahkvk, Беседа в VK [ новости об обновлениях | тех. поддержка ]
Gui, Add, Button, x13 y310 w390 h20 ginst, Инструкция [ скачивание | установка | запуск ]

Gui Font, s7 White Bold, Gilory
Gui, Add, Text, x325 y388 w999 h30 , by German_McKenzy
Gui, Add, Text, x5 y388 w111 h30 , v%currentversion%
return

mzforum:
run, https://forum.gtaprovince.ru/forum/68-ministerstvo-zdravoohraneniya/
return

pomz:
run, https://forum.gtaprovince.ru/topic/909573-pomz-polozhenie-o-ministerstve-zdravoohraneniya/
return

info:
run, https://forum.gtaprovince.ru/topic/907584-informacionnyy-razdel/
return

rosmp:
run, https://forum.gtaprovince.ru/topic/907537-reglament-okazaniya-skoroy-medicinskoy-pomoschi/
return

ballsys:
run, https://forum.gtaprovince.ru/topic/907247-edinaya-ballnaya-sistema-mz/
return

pdsf:
run, https://forum.gtaprovince.ru/topic/841868-pravila-dlya-sotrudnikov-frakciy-pdsf/
return

pdfr:
run, https://forum.gtaprovince.ru/topic/841870-pravila-dlya-frakcionnogo-rukovodstva-pdfr/
return

calend:
run, https://forum.gtaprovince.ru/topic/895035-proizvodstvennyy-kalendar-na-2025-god/
return

perevod:
run, https://forum.gtaprovince.ru/topic/842753-pravila-perevoda-i-vosstanovleniya-sotrudnikov/
return

ochs:
run, https://gtajournal.online/fbl
return

novost:
run, https://vk.com/2province_frac
return

mzvk:
run, https://vk.com/mz_server02
return

calk:
run, https://vk.cc/cJC9Pr
return

ahkvk:
run, https://vk.me/join/E6QeXGryXUyS9pF8OWJTyZiH7lYXfWv_eQs=
return

inst:
run, https://telegra.ph/Instrukciya-po-ustanovke-i-ispolzovaniyu-AHK-03-11
return
;________________________________________________________________________________________________________________________________________________________________________________________
^1::
SendMessage, 0x50,, 0x4190419,, A
sendplay {T}|
sleep 122
sendplay Здравствуйте, я %Rang% %City% %FIO%. {enter}
sleep 111
sendplay {T}
sleep 111
sendplay /do На бейдже информация: %Rang% | %City% | %FIO%. {enter}
return

^2::
SendMessage, 0x50,, 0x4190419,, A
sendplay {T}|
sleep 122
sendplay Чем могу Вам помочь? {enter}
return

^3::
SendMessage, 0x50,, 0x4190419,, A
sendplay {T}|
sleep 122
sendplay Я пропишу Вам миг, его стоимость 500 рублей, Вы согласны? {enter}
return

^4::
SendMessage, 0x50,, 0x4190419,, A
sendplay {f8}
sleep 122
SendPlay ^A{Delete}
sleep 333
sendplay do В медицинской сумке лежит необходимое лекарство, бланк выписки и ручка. {enter}
sleep 111
sendplay me открыв сумку, достал бланк и ручку, затем начал заполнять бланк {enter}
sleep 111
sendplay todo Возьмите, пожалуйста, бланк выписки и лекарство*заполнив бланк, затем достав лекарство и положив ручку в сумку {enter}
sleep 111
sendplay b Пропишите в обычном чате: /me взял лекарство{enter}{f8}
sleep 111
sendplay {T}
sleep 222
sendplay /helpmed{space}
return

^5::
SendMessage, 0x50,, 0x4190419,, A
sendplay {T}|
sleep 122
sendplay /do В медицинской сумке находятся медицинские препараты. {enter}
sleep 111
sendplay {T}
sleep 111
sendplay /me открыв сумку, достал необходимое лекарство и употребил его {enter}
return

:*?:рация1::
SendMessage, 0x50,, 0x4190419,, A 
sleep 100
sendplay {esc}
sleep 100
sendplay {F8}
sleep 100
sendplay какую рацию желаете использовать (d | r | ro):{space}
Input TryRes, V, {Enter}
if(TryRes=="d")||(TryRes=="D")||(TryRes=="в")||(TryRes=="В")
 {
       SendPlay ^A{Delete}
       sleep 100
       sendplay, do На поясе сотрудника висит рабочая рация. {enter}
       sleep 100
       sendplay me сняв рацию с пояса, нажал на тангенту и что-то сказал в неё {enter}
       sleep 100
       sendplay d [%City%]{space}
       keywait, Enter, D
       sleep 122
       sendplay, me закончив переговоры, отпустил тангенту и повесил рацию на пояс {enter}
       sleep 100
       sendplay {f8}
 } 
if(TryRes=="r")||(TryRes=="R")||(TryRes=="к")||(TryRes=="К")
   {
       SendPlay ^A{Delete}
       sleep 120
       sendplay, do На поясе сотрудника висит рабочая рация. {enter}
       sleep 100
       sendplay me сняв рацию с пояса, нажал на тангенту и что-то сказал в неё {enter}
       sleep 100
       sendplay r [%Tag%]{space}
       keywait, Enter, D
       sleep 122
       sendplay, me закончив переговоры, отпустил тангенту и повесил рацию на пояс {enter}
       sleep 100
       sendplay {f8}
   }
if(TryRes=="ro")||(TryRes=="RO")||(TryRes=="кщ")||(TryRes=="КЩ")
   {
       SendPlay ^A{Delete}
       sleep 120
       sendplay, do На поясе сотрудника висит рабочая рация. {enter}
       sleep 100
       sendplay me сняв рацию с пояса, нажал на тангенту и что-то сказал в неё {enter}
       sleep 100
       sendplay ro [%City%]{space}
       keywait, Enter, D
       sleep 111
       sendplay, me закончив переговоры, отпустил тангенту и повесил рацию на пояс {enter}
       sleep 100
       sendplay {f8}
   }
return

:*?:смена1::
SendMessage, 0x50,, 0x4190419,, A 
blockinput, on
sendplay {esc}
sleep 100
sendplay {f8}
sleep 150
sendplay fracvoice 2 {enter}
sleep 170
sendplay, do На поясе сотрудника висит рабочая рация. {enter}
sleep 100
sendplay me сняв рацию с пояса, нажал на тангенту и что-то сказал в неё {enter}
sleep 100
sendplay r [%Tag%] Заступил на смену. {enter}
sleep 100
sendplay me закончив переговоры, отпустил тангенту и повесил рацию на пояс {enter}{f8}
blockinput, off
return

:*?:смена2::
SendMessage, 0x50,, 0x4190419,, A 
blockinput, on
sendplay {esc}
sleep 100
sendplay {f8}
sleep 150
sendplay, do На поясе сотрудника висит рабочая рация. {enter}
sleep 100
sendplay me сняв рацию с пояса, нажал на тангенту и что-то сказал в неё {enter}
sleep 100
sendplay r [%Tag%] Сдал смену. {enter}
sleep 100
sendplay me закончив переговоры, отпустил тангенту и повесил рацию на пояс {enter}{f8}
blockinput, off
return

; -------------------------------- вызов ---------------------------------

:*?:вызовн1::
global Tag, Partners
SendMessage, 0x50,, 0x4190419,, A 
sleep 100
sendplay {esc}
sleep 100
sendplay {F8}
sleep 100
       SendPlay ^A{Delete}
       sleep 1111
sendplay какой отчет желаете сделать? (принял | прибыл | увожу | отменен | ложный | обработан):{space}
Input TryRes, V, {Enter}
if(TryRes=="принял")||(TryRes=="пghbyzk")
 {
       SendPlay ^A{Delete}
       sleep 200
       sendplay, do На поясе сотрудника висит рабочая рация. {enter}
       sleep 200
       sendplay me сняв рацию с пояса, нажал на тангенту и что-то сказал в неё {enter}
       sleep 200
       sendplay каков номер вызова -->{space}
       input, Nomer1, V, {enter}
       sleep 111
       sendplay r [%Tag%] Принял вызов №%Nomer1%. Напарник: %Partners% {enter}
       sleep 111
       Gosub, razia
       return
    if (StopScript := true)
        return
 } 
if(TryRes=="прибыл")||(TryRes=="ghb,sk")
   {
       SendPlay ^A{Delete}
       sleep 120
       sendplay, do На поясе сотрудника висит рабочая рация. {enter}
       sleep 100
       sendplay me сняв рацию с пояса, нажал на тангенту и что-то сказал в неё {enter}
       sleep 100
       sendplay r [%Tag%] Прибыл на место вызова. Напарник: %Partners% {enter}
       sleep 111
       Gosub, razia
       return
   }
if(TryRes=="увожу")||(TryRes=="edj;e")
   {
       SendPlay ^A{Delete}
       sleep 120
       sendplay, do На поясе сотрудника висит рабочая рация. {enter}
       sleep 100
       sendplay me сняв рацию с пояса, нажал на тангенту и что-то сказал в неё {enter}
       sleep 100
       sendplay r [%Tag%] Госпитализирую пациента в больницу. Напарник: %Partners% {enter}
       sleep 111
       Gosub, razia
       return
   }
if(TryRes=="отменен")||(TryRes=="jnvtyty")
   {
       SendPlay ^A{Delete}
       sleep 120
       sendplay, do На поясе сотрудника висит рабочая рация. {enter}
       sleep 100
       sendplay me сняв рацию с пояса, нажал на тангенту и что-то сказал в неё {enter}
       sleep 100
       sendplay r [%Tag%] Вызов отменен. Напарник: %Partners% {enter}
       sleep 111
       Gosub, razia
       return
   }
if(TryRes=="ложный")||(TryRes=="kj;ysq")
 {
       SendPlay ^A{Delete}
       sleep 120
       sendplay, do На поясе сотрудника висит рабочая рация. {enter}
       sleep 100
       sendplay me сняв рацию с пояса, нажал на тангенту и что-то сказал в неё {enter}
       sleep 100
       sendplay r [%Tag%] Вызов оказался ложным. Напарник: %Partners% {enter}
       sleep 111
       Gosub, razia
       return
   }
if(TryRes=="обработан")||(TryRes=="j,hf,jnfy")
 {
       SendPlay ^A{Delete}
       sleep 120
       sendplay, do На поясе сотрудника висит рабочая рация. {enter}
       sleep 100
       sendplay me сняв рацию с пояса, нажал на тангенту и что-то сказал в неё {enter}
       sleep 100
       sendplay r [%Tag%] Вызов обработан на месте. Напарник: %Partners% {enter}
       sleep 111
       Gosub, razia
       return
   }

:*?:вызов1::
global Tag, Partners
SendMessage, 0x50,, 0x4190419,, A 
sleep 100
sendplay {esc}
sleep 100
sendplay {F8}
sleep 100
SendPlay ^A{Delete}
sleep 1111
sendplay какой отчет желаете сделать? ( принял | прибыл | увожу |  отменен | ложный | обработан):{space}
Input TryRes, V, {Enter}
if(TryRes=="принял")||(TryRes=="пghbyzk")
 {
       SendPlay ^A{Delete}
       sleep 444
       sendplay, do На поясе сотрудника висит рабочая рация. {enter}
       sleep 100
       sendplay me сняв рацию с пояса, нажал на тангенту и что-то сказал в неё {enter}
       sleep 100
       sendplay каков номер вызова -->{space}
       input, Nomer1, V, {enter}
       sleep 111
       sendplay r [%Tag%] Принял вызов №%Nomer1%. {enter}
       sleep 111
       Gosub, razia
       return
 } 
if(TryRes=="прибыл")||(TryRes=="ghb,sk")
   {
       SendPlay ^A{Delete}
       sleep 444
       sendplay, do На поясе сотрудника висит рабочая рация. {enter}
       sleep 100
       sendplay me сняв рацию с пояса, нажал на тангенту и что-то сказал в неё {enter}
       sleep 100
       sendplay r [%Tag%] Прибыл на место вызова. {enter}
       sleep 111
       Gosub, razia
       return
   }
if(TryRes=="увожу")||(TryRes=="edj;e")
   {
       SendPlay ^A{Delete}
       blockinput, on
       sleep 444
       sendplay, do На поясе сотрудника висит рабочая рация. {enter}
       sleep 100
       sendplay me сняв рацию с пояса, нажал на тангенту и что-то сказал в неё {enter}
       sleep 100
       sendplay r [%Tag%] Госпитализирую пациента в больницу. {enter}
       sleep 111
       Gosub, razia
       blockinput, off
       return
   }
if(TryRes=="отменен")||(TryRes=="jnvtyty")
   {
       SendPlay ^A{Delete}
       sleep 444
       sendplay, do На поясе сотрудника висит рабочая рация. {enter}
       sleep 100
       sendplay me сняв рацию с пояса, нажал на тангенту и что-то сказал в неё {enter}
       sleep 100
       sendplay r [%Tag%] Вызов отменен.{enter}
       sleep 111
       Gosub, razia
       return
   }
if(TryRes=="ложный")||(TryRes=="kj;ysq")
 {
       SendPlay ^A{Delete}
       sleep 444
       sendplay, do На поясе сотрудника висит рабочая рация. {enter}
       sleep 100
       sendplay me сняв рацию с пояса, нажал на тангенту и что-то сказал в неё {enter}
       sleep 100
       sendplay r [%Tag%] Вызов оказался ложным.{enter}
       sleep 111
       Gosub, razia
       return
   }
if(TryRes=="обработан")||(TryRes=="j,hf,jnfy")
 {
       SendPlay ^A{Delete}
       sleep 444
       sendplay, do На поясе сотрудника висит рабочая рация. {enter}
       sleep 100
       sendplay me сняв рацию с пояса, нажал на тангенту и что-то сказал в неё {enter}
       sleep 100
       sendplay r [%Tag%] Вызов обработан на месте. {enter}
       sleep 111
       Gosub, razia
       return
   }

return

razia:
  sendplay {f8}
  sleep 122
  sendplay {T}
  sleep 122
  sendplay, /me закончив переговоры, отпустил тангенту и повесил рацию на пояс {enter}
return

:*?:созн1::
SendMessage, 0x50,, 0x4190419,, A 
sendplay {esc}
sleep 100
sendplay {f8}
sleep 150
SendPlay ^A{Delete}
sleep 555
sendplay, do Человек в сознании{?} {enter}
sleep 100
sendplay, b {/}do Да. | {/}do Нет. {enter}
sleep 100
sendplay Что ответил? Введите да или нет (в любой раскладке):{space}
Input TryRes, V, {Enter}
if(TryRes=="да")||(TryRes=="lf")||(TryRes=="ДА")||(TryRes=="LF")
 {
sleep 122
       SendPlay ^A{Delete}
sleep 122
       sendplay, me дёрнув за рычаг, опустил каталку до нужного уровня{enter}
sleep 111
sendplay me напрягшись и схватившись за тело пациента, положил его на каталку{enter}
sleep 111
sendplay me вернул каталку в прежнее состояние{enter}{f8}
return 
 } 
if(TryRes=="нет")||(TryRes=="ytn")||(TryRes=="НЕТ")||(TryRes=="YTN")
   {
       blockinput, on
       SendPlay ^A{Delete}
       sleep 555
       sendplay me подставив 2 пальца к задней стороне запястья пострадавшего, отсчитал количество ударов {enter}
       sleep 333
       sendplay, do В медицинской сумке находятся необходимые препараты. {enter}
       sleep 500
       sendplay, me убрав руку с запястья, открыл сумку и достал нашатырный спирт с ваткой {enter}
       sleep 900
       sendplay, me смочив ватку спиртом, поднёс её к носу пострадавшего {enter}
       sleep 1200
       sendplay, me убрав спирт в сумку, закрыл её {enter}
       sleep 400
       sendplay, do Человек пришел сознание? {enter}
       sleep 100
       sendplay, b {/}do Да. или {/}do Нет. {enter}
       blockinput, off
       sleep 100
       sendplay Что ответил? Введите да или нет (в любой раскладке):{space}
       Input TryRes, V, {Enter}
       if(TryRes=="да")||(TryRes=="lf")||(TryRes=="ДА")||(TryRes=="LF")
        {
       sleep 122
       SendPlay ^A{Delete}
       sleep 444
       sendplay, me дёрнув за рычаг, опустил каталку до нужного уровня{enter}
       sleep 111
       sendplay me напрягшись и схватившись за тело пациента, положил его на каталку{enter}
       sleep 111
       sendplay me вернул каталку в прежнее состояние{enter}{f8}
       return 
        } 
       if(TryRes=="нет")||(TryRes=="ytn")||(TryRes=="НЕТ")||(TryRes=="YTN")
   {
       sleep 122
       SendPlay ^A{Delete}
       sleep 444
       sendplay, me дёрнув за рычаг, опустил каталку до нужного уровня{enter}
       sleep 111
       sendplay me напрягшись и схватившись за тело пациента, положил его на каталку{enter}
       sleep 111
       sendplay me вернул каталку в прежнее состояние{enter}{f8}
      return 
        return
   }
 }
return
;________________________________________________________________________________________________________________________________________________________________________________________
!1::
SendMessage, 0x50,, 0x4190419,, A
sendplay {f8}
sleep 120
sendplay ^A{Delete}
sleep 122
sendplay me дёрнув за рычаг, опустил каталку до нужного уровня {enter}
sleep 100
sendplay me напрягшись и схватившись за тело пациента, положил его на каталку {enter}
sleep 111
sendplay me вернул каталку в прежнее состояние {enter}{f8}
return

!2::
SendMessage, 0x50,, 0x4190419,, A
sendplay {f8}
sleep 120
sendplay ^A{Delete}
sleep 1111
sendplay вертолет или карета (в | к):{space}
Input TryRes, V, {enter}
if(TryRes=="в")||(TryRes=="d")
{
sendplay ^A{Delete}
sleep 122
sendplay имеется ли напарник? (да | нет):{space}
Input TryRes, V, {enter}
if(TryRes=="да")||(TryRes=="lf")
{
sendplay ^A{Delete}
sleep 444
sendplay do На поясе сотрудника висит рабочая рация. {enter}
sleep 120
sendplay me сняв рацию с пояса, нажал на тангенту и что-то сказал в неё, вызвав дежурного врача {enter}
sleep 120
sendplay r [%Tag%] Пациент госпитализирован. Вызов обработан. Напарник: %Partners% {enter}
sleep 300
sendplay do Дежурный врач, подойдя к вертолету СМП, открыл задние двери вертолета и забрал каталку с пациентом,увёзя её в приёмное отделение. {enter}
sleep 100
sendplay {f8}
sleep 100
sendplay {R}
sleep 777
sendplay {f12}
}
if(TryRes=="нет")||(TryRes=="ytn")
{
sendplay ^A{Delete}
sleep 444
sendplay do На поясе сотрудника висит рабочая рация. {enter}
sleep 120
sendplay me сняв рацию с пояса, нажал на тангенту и что-то сказал в неё, вызвав дежурного врача {enter}
sleep 120
sendplay r [%Tag%] Пациент госпитализирован. Вызов обработан. {enter}
sleep 300
sendplay do Дежурный врач, подойдя к вертолету СМП, открыл задние двери вертолета и забрал каталку с пациентом,увёзя её в приёмное отделение. {enter}
sleep 100
sendplay {f8}
sleep 100
sendplay {R}
sleep 777
sendplay {f12}
}
 }
if(TryRes=="к")||(TryRes=="r")
{
sendplay ^A{Delete}
sleep 122
sendplay имеется ли напарник? (да | нет):{space}
Input TryRes, V, {enter}
if(TryRes=="да")||(TryRes=="lf")
{
sendplay ^A{Delete}
sleep 444
sendplay do На поясе сотрудника висит рабочая рация. {enter}
sleep 120
sendplay me сняв рацию с пояса, нажал на тангенту и что-то сказал в неё, вызвав дежурного врача {enter}
sleep 120
sendplay r [%Tag%] Пациент госпитализирован. Вызов обработан. Напарник: %Partners% {enter}
sleep 300
sendplay do Дежурный врач, подойдя к карете СМП, открыл задние двери кареты и забрал каталку с пациентом,увёзя её в приёмное отделение. {enter}
sleep 100
sendplay {f8}
sleep 100
sendplay {R}
sleep 777
sendplay {f12}
}
if(TryRes=="нет")||(TryRes=="ytn")
{
sendplay ^A{Delete}
sleep 444
sendplay do На поясе сотрудника висит рабочая рация. {enter}
sleep 120
sendplay me сняв рацию с пояса, нажал на тангенту и что-то сказал в неё, вызвав дежурного врача {enter}
sleep 120
sendplay r [%Tag%] Пациент госпитализирован. Вызов обработан. {enter}
sleep 300
sendplay do Дежурный врач, подойдя к карете СМП, открыл задние двери кареты и забрал каталку с пациентом,увёзя её в приёмное отделение. {enter}
sleep 100
sendplay {f8}
sleep 100
sendplay {R}
sleep 777
sendplay {f12}
}
 }
return

;------------------------------------------------------------- медкарта -------------------------------------------------------------------
:*?:медкарта1::
SendMessage, 0x50,, 0x4190419,, A
sendplay {esc}
sleep 111
sendplay {f8}
sleep 120
sendplay ^A{Delete}
sleep 1111
sendplay say Вы получаете мед. карту впервые или желаете продлить ее? {enter}
sleep 111
sendplay do В медицинской сумке лежит клипборд с закреплённым бланком и ручкой. {enter}
sleep 120
sendplay todo Для оформления мне нужен документ, удостоверяющий вашу личность*доставая клипборд из сумки {enter}
sleep 120
sendplay b покажите мне паспорт или уд (через таб) {enter}
sleep 111
sendplay для продолжения выдачи нажмите ПРАВЫЙ CONTROL (в консоли)
keywait, RControl, D
sleep 111
sendplay ^A{Delete}
sleep 1111
sendplay me взглянув на документы, изучил их и занес нужную информацию в базу данных {enter}{f8}
return


:*?:медпсих1::
SendMessage, 0x50,, 0x4190419,, A
sendplay {esc}
sleep 111
sendplay {f8}
sleep 120
sendplay ^A{Delete}
sleep 1111
sendplay say Приступим. До моего указания вам нельзя покидать кабинет. Установим ваше психическое состояние. Как себя чувствуете? {enter}
sleep 120
sendplay для продолжения выдачи нажмите ПРАВЫЙ CONTROL (в консоли)
keywait, RControl, D
sleep 111
sendplay ^A{Delete}
sleep 1111
sendplay say Угу... Как можно расшифровать аббревиатуры "МГ, СК, РП"? {enter}
sleep 120
sendplay для продолжения выдачи нажмите ПРАВЫЙ CONTROL (в консоли)
keywait, RControl, D
sleep 111
sendplay ^A{Delete}
sleep 1111
sendplay b Теперь вам нужно выйти из кабинета, я заполню нужные данные. {enter}{f8}
return


:*?:медфиз1::
SendMessage, 0x50,, 0x4190419,, A
sendplay {esc}
sleep 111
sendplay {f8}
sleep 120
sendplay ^A{Delete}
sleep 1111
sendplay say Теперь изучим ваше физическое состояние. Сейчас я измерю давление, вытягивайте левую руку и закатайте рукав. {enter}
sleep 111
sendplay b /me закатав рукав, вытянул левую руку {enter}
sleep 111
sendplay для продолжения выдачи нажмите ПРАВЫЙ CONTROL (в консоли)
keywait, RControl, D
sleep 111
sendplay ^A{Delete}
sleep 1111
sendplay do На столе расположен тонометр. {enter}
sleep 111
sendplay me взяв тонометр со стола, закрепив его на руке у пациента, включил прибор {enter}
sleep 111
sendplay do Какое значение показал прибор? {enter}
sleep 111
sendplay b обычные показатели давления - 120/80 | отыграть через /do {enter}
sleep 111
sendplay для продолжения выдачи нажмите ПРАВЫЙ CONTROL (в консоли)
keywait, RControl, D
sleep 111
sendplay ^A{Delete}
sleep 1111
sendplay me сняв тонометр, положил его на стол, записал данные в бланк {enter}
sleep 111
sendplay todo Теперь измерим вашу температуру*достав из мед. сумки термометр, направил его на лоб человека напротив {enter}
sleep 111
sendplay do Какая температура у пациента? {enter}
sleep 111
sendplay b обычная температура - 36.6 | отыграть через /do {enter}
sleep 111
sendplay для продолжения выдачи нажмите ПРАВЫЙ CONTROL (в консоли)
keywait, RControl, D
sleep 111
sendplay ^A{Delete}
sleep 1111
sendplay todo Температура в норме*убрав термометр и записав данные в бланк {enter}
sleep 111
sendplay me взяв новую медицинскую карту, оформил ее, занес данные в базу, поставил штамп и протянул человеку напротив {enter}
sleep 111
sendplay b /me взял новую мед. карту {enter}
sleep 111
sendplay {F8}
return

;________________________________________________________________________________________________________________________________________________________________________________________

:*?:п1::
Sendmessage, 0x50,, 0x4190419,, A
sleep 250
sendplay {esc}
sleep 111
sendplay {f8}
sleep 111
sendplay ^A{Delete}
sleep 111
sendplay, do На поясе сотрудника висит рабочая рация. {enter}
sleep 111
sendplay me сняв рацию с пояса, нажал на тангенту и что-то сказал в неё {enter}
sleep 111
sendplay выехал | прод | завершил -->{space}
Input TryRes, V, {enter}
if(TryRes=="выехал")||(TryRes=="dst[fk")
{
sleep 150
sendplay вертолет / карета (в | к) -->{space}
Input TryRes, V, {enter}
if(TryRes=="в")||(TryRes=="d")
{
sleep 150
sendplay r [%Tag%] Вылетел в свободное патрулирование города.{enter}
sleep 111
Gosub, razia
return
}
if(TryRes=="к")||(TryRes=="r")
{
sleep 150
sendplay r [%Tag%] Выехал в свободное патрулирование города.{enter}
sleep 111
Gosub, razia
return
 }
}
if(TryRes=="прод")||(TryRes=="ghjl")
{
sendplay r [%Tag%] Продолжаю свободное патрулирование города.{enter}
sleep 111
Gosub, razia
return
}
if(TryRes=="завершил")||(TryRes=="pfdthibk")
{
sendplay r [%Tag%] Завершил свободное патрулирование города.{enter}
sleep 111
Gosub, razia
return
}
return

:*?:пн1::
Sendmessage, 0x50,, 0x4190419,, A
sleep 250
sendplay {esc}
sleep 111
sendplay {f8}
sleep 111
sendplay ^A{Delete}
sleep 111
sendplay, do На поясе сотрудника висит рабочая рация. {enter}
sleep 111
sendplay me сняв рацию с пояса, нажал на тангенту и что-то сказал в неё {enter}
sleep 111
sendplay выехал | прод | завершил -->{space}
Input TryRes, V, {enter}
if(TryRes=="выехал")||(TryRes=="dst[fk")
{
sleep 150
sendplay вертолет / карета (в | к) -->{space}
Input TryRes, V, {enter}
if(TryRes=="в")||(TryRes=="d")
{
sleep 150
sendplay r [%Tag%] Вылетел в свободное патрулирование города. Напарник: %Partners%{enter}
sleep 111
Gosub, razia
return
}
if(TryRes=="к")||(TryRes=="r")
{
sleep 150
sendplay r [%Tag%] Выехал в свободное патрулирование города. Напарник: %Partners%{enter}
sleep 111
Gosub, razia
return
 }
}
if(TryRes=="прод")||(TryRes=="ghjl")
{
sendplay r [%Tag%] Продолжаю свободное патрулирование города. Напарник: %Partners%{enter}
sleep 111
Gosub, razia
return
}
if(TryRes=="завершил")||(TryRes=="pfdthibk")
{
sendplay r [%Tag%] Завершил свободное патрулирование города. Напарник: %Partners%{enter}
sleep 111
Gosub, razia
return
}
return
;________________________________________________________________________________________________________________________________________________________________________________________
:*?:пркн1::
Sendmessage, 0x50,, 0x4190419,, A
sleep 250
sendplay {esc}
sleep 111
sendplay {f8}
sleep 111
sendplay ^A{Delete}
sleep 111
sendplay, do На поясе сотрудника висит рабочая рация. {enter}
sleep 111
sendplay me сняв рацию с пояса, нажал на тангенту и что-то сказал в неё {enter}
sleep 111
sendplay выехал | прод | завершил -->{space}
Input TryRes, V, {enter}
if(TryRes=="выехал")||(TryRes=="dst[fk")
{
sendplay ro [%City%] Выехал в свободное патрулирование Республики. Напарник: %Partners%{enter}
sleep 111
Gosub, razia
return
}
if(TryRes=="прод")||(TryRes=="ghjl")
{
sendplay ro [%City%] Продолжаю свободное патрулирование Республики. Напарник: %Partners%{enter}
sleep 111
Gosub, razia
return
}
if(TryRes=="завершил")||(TryRes=="pfdthibk")
{
sendplay ro [%City%] Завершил свободное патрулирование Республики. Напарник: %Partners%{enter}
sleep 111
Gosub, razia
return
}
return
;________________________________________________________________________________________________________________________________________________________________________________________
:*?:првн1::
Sendmessage, 0x50,, 0x4190419,, A
sleep 250
sendplay {esc}
sleep 111
sendplay {f8}
sleep 111
sendplay ^A{Delete}
sleep 111
sendplay, do На поясе сотрудника висит рабочая рация. {enter}
sleep 111
sendplay me сняв рацию с пояса, нажал на тангенту и что-то сказал в неё {enter}
sleep 111
sendplay вылетел | прод | завершил -->{space}
Input TryRes, V, {enter}
if(TryRes=="вылетел")||(TryRes=="dsktntk")
{
sendplay ro [%City%] Вылетел в воздушное патрулирование Республики. Напарник: %Partners%{enter}
sleep 111
Gosub, razia
return
}
if(TryRes=="прод")||(TryRes=="ghjl")
{
sendplay ro [%City%] Продолжаю воздушное патрулирование Республики. Напарник: %Partners%{enter}
sleep 111
Gosub, razia
return
}
if(TryRes=="завершил")||(TryRes=="pfdthibk")
{
sendplay ro [%City%] Завершил воздушное патрулирование Республики. Напарник: %Partners%{enter}
sleep 111
Gosub, razia
return
}
return
;________________________________________________________________________________________________________________________________________________________________________________________
:*?:прк1::
Sendmessage, 0x50,, 0x4190419,, A
sleep 250
sendplay {esc}
sleep 111
sendplay {f8}
sleep 111
sendplay ^A{Delete}
sleep 111
sendplay, do На поясе сотрудника висит рабочая рация. {enter}
sleep 111
sendplay me сняв рацию с пояса, нажал на тангенту и что-то сказал в неё {enter}
sleep 111
sendplay выехал | прод | завершил -->{space}
Input TryRes, V, {enter}
if(TryRes=="выехал")||(TryRes=="dst[fk")
{
sendplay ro [%City%] Выехал в свободное патрулирование Республики.{enter}
sleep 111
Gosub, razia
return
}
if(TryRes=="прод")||(TryRes=="ghjl")
{
sendplay ro [%City%] Продолжаю свободное патрулирование Республики.{enter}
sleep 111
Gosub, razia
return
}
if(TryRes=="завершил")||(TryRes=="pfdthibk")
{
sendplay ro [%City%] Завершил свободное патрулирование Республики.{enter}
sleep 111
Gosub, razia
return
}
return
;________________________________________________________________________________________________________________________________________________________________________________________
:*?:прв1::
Sendmessage, 0x50,, 0x4190419,, A
sleep 250
sendplay {esc}
sleep 111
sendplay {f8}
sleep 111
sendplay ^A{Delete}
sleep 111
sendplay, do На поясе сотрудника висит рабочая рация. {enter}
sleep 111
sendplay me сняв рацию с пояса, нажал на тангенту и что-то сказал в неё {enter}
sleep 111
sendplay вылетел | прод | завершил -->{space}
Input TryRes, V, {enter}
if(TryRes=="вылетел")||(TryRes=="dsktntk")
{
sendplay ro [%City%] Вылетел в воздушное патрулирование Республики.{enter}
sleep 111
Gosub, razia
return
}
if(TryRes=="прод")||(TryRes=="ghjl")
{
sendplay ro [%City%] Продолжаю воздушное патрулирование Республики.{enter}
sleep 111
Gosub, razia
return
}
if(TryRes=="завершил")||(TryRes=="pfdthibk")
{
sendplay ro [%City%] Завершил воздушное патрулирование Республики.{enter}
sleep 111
Gosub, razia
return
}
return
;________________________________________________________________________________________________________________________________________________________________________________________
:*?:пост1::
Sendmessage, 0x50,, 0x4190419,, A
sleep 250
sendplay {esc}
sleep 111
sendplay {f8}
sleep 111
sendplay ^A{Delete}
sleep 111
sendplay, do На поясе сотрудника висит рабочая рация. {enter}
sleep 111
sendplay me сняв рацию с пояса, нажал на тангенту и что-то сказал в неё {enter}
sleep 111
sendplay выехал | прибыл | прод | завершил -->{space}
Input TryRes, V, {enter}
if(TryRes=="выехал")||(TryRes=="dsktntk")
{
sleep 150
sendplay r [%Tag%] Выехал на пост №%Post%. {enter}
sleep 111
Gosub, razia
return
}
if(TryRes=="прибыл")||(TryRes=="ghb,sk")
{
sleep 150
sendplay r [%Tag%] Прибыл на пост №%Post%. {enter}
sleep 111
Gosub, razia
return
}
if(TryRes=="прод")||(TryRes=="ghjl")
{
sleep 150
sendplay r [%Tag%] Продолжаю стоянку на посту №%Post%. {enter}
sleep 111
Gosub, razia
return
}
if(TryRes=="завершил")||(TryRes=="pfdthibk")
{
sleep 150
sendplay r [%Tag%] Завершил стоянку на посту №%Post%. {enter}
sleep 111
Gosub, razia
return
}
return
;________________________________________________________________________________________________________________________________________________________________________________________
:*?:постн1::
Sendmessage, 0x50,, 0x4190419,, A
sleep 250
sendplay {esc}
sleep 111
sendplay {f8}
sleep 111
sendplay ^A{Delete}
sleep 111
sendplay, do На поясе сотрудника висит рабочая рация. {enter}
sleep 111
sendplay me сняв рацию с пояса, нажал на тангенту и что-то сказал в неё {enter}
sleep 111
sendplay выехал | прибыл | прод | завершил -->{space}
Input TryRes, V, {enter}
if(TryRes=="выехал")||(TryRes=="dsktntk")
{
sleep 150
sendplay r [%Tag%] Выехал на пост №%Post%. Напарник: %Partners%.{enter}
sleep 111
Gosub, razia
return
}
if(TryRes=="прибыл")||(TryRes=="ghb,sk")
{
sleep 150
sendplay r [%Tag%] Прибыл на пост №%Post%. Напарник: %Partners%.{enter}
sleep 111
Gosub, razia
return
}
if(TryRes=="прод")||(TryRes=="ghjl")
{
sleep 150
sendplay r [%Tag%] Продолжаю стоянку на посту №%Post%. Напарник: %Partners%.{enter}
sleep 111
Gosub, razia
return
}
if(TryRes=="завершил")||(TryRes=="pfdthibk")
{
sleep 150
sendplay r [%Tag%] Завершил стоянку на посту №%Post%. Напарник: %Partners%.{enter}
sleep 111
Gosub, razia
return
}
return
;________________________________________________________________________________________________________________________________________________________________________________________
:*?:постверт1::
Sendmessage, 0x50,, 0x4190419,, A
sleep 250
sendplay {esc}
sleep 111
sendplay {f8}
sleep 111
sendplay ^A{Delete}
sleep 111
sendplay, do На поясе сотрудника висит рабочая рация. {enter}
sleep 111
sendplay me сняв рацию с пояса, нажал на тангенту и что-то сказал в неё {enter}
sleep 111
sendplay вылетел | прибыл | прод | завершил -->{space}
Input TryRes, V, {enter}
if(TryRes=="вылетел")||(TryRes=="dsktntk")
{
sleep 150
sendplay r [%Tag%] Вылетел на вертолетный пост №%Post%. {enter}
sleep 111
Gosub, razia
return
}
if(TryRes=="прибыл")||(TryRes=="ghb,sk")
{
sleep 150
sendplay r [%Tag%] Прибыл на вертолетный пост №%Post%. {enter}
sleep 111
Gosub, razia
return
}
if(TryRes=="прод")||(TryRes=="ghjl")
{
sleep 150
sendplay r [%Tag%] Продолжаю стоянку на вертолетном посту №%Post%. {enter}
sleep 111
Gosub, razia
return
}
if(TryRes=="завершил")||(TryRes=="pfdthibk")
{
sleep 150
sendplay r [%Tag%] Завершил стоянку на вертолетном посту №%Post%. {enter}
sleep 111
Gosub, razia
return
}
return
;________________________________________________________________________________________________________________________________________________________________________________________
:*?:поствертн1::
Sendmessage, 0x50,, 0x4190419,, A
sleep 250
sendplay {esc}
sleep 111
sendplay {f8}
sleep 111
sendplay ^A{Delete}
sleep 111
sendplay, do На поясе сотрудника висит рабочая рация. {enter}
sleep 111
sendplay me сняв рацию с пояса, нажал на тангенту и что-то сказал в неё {enter}
sleep 111
sendplay вылетел | прибыл | прод | завершил -->{space}
Input TryRes, V, {enter}
if(TryRes=="вылетел")||(TryRes=="dsktntk")
{
sleep 150
sendplay r [%Tag%] Вылетел на вертолетный пост №%Post%. Напарник: %Partners%.{enter}
sleep 111
Gosub, razia
return
}
if(TryRes=="прибыл")||(TryRes=="ghb,sk")
{
sleep 150
sendplay r [%Tag%] Прибыл на вертолетный пост №%Post%. Напарник: %Partners%.{enter}
sleep 111
Gosub, razia
return
}
if(TryRes=="прод")||(TryRes=="ghjl")
{
sleep 150
sendplay r [%Tag%] Продолжаю стоянку вертолетном на посту №%Post%. Напарник: %Partners%.{enter}
sleep 111
Gosub, razia
return
}
if(TryRes=="завершил")||(TryRes=="pfdthibk")
{
sleep 150
sendplay r [%Tag%] Завершил стоянку на вертолетном посту №%Post%. Напарник: %Partners%.{enter}
sleep 111
Gosub, razia
return
}
return
;________________________________________________________________________________________________________________________________________________________________________________________
:*?:дежсобес1::
Sendmessage, 0x50,, 0x4190419,, A
sleep 250
sendplay {esc}
sleep 111
sendplay {f8}
sleep 111
sendplay ^A{Delete}
sleep 111
sendplay, do На поясе сотрудника висит рабочая рация. {enter}
sleep 111
sendplay me сняв рацию с пояса, нажал на тангенту и что-то сказал в неё {enter}
sleep 111
sendplay выехал | прибыл | прод | завершил -->{space}
Input TryRes, V, {enter}
if(TryRes=="выехал")||(TryRes=="dst[fk")
{
sleep 150
sendplay r [%Tag%] Выехал на дежурство собеседования %Frac%.{enter}
sleep 111
Gosub, razia
return
}
if(TryRes=="прибыл")||(TryRes=="ghb,sk")
{
sleep 150
sendplay r [%Tag%] Прибыл на дежурство собеседования %Frac%.{enter}
sleep 111
Gosub, razia
return
}
if(TryRes=="прод")||(TryRes=="ghjl")
{
sleep 150
sendplay r [%Tag%] Продолжаю дежурство на собеседовании %Frac%.{enter}
sleep 111
Gosub, razia
return
}
if(TryRes=="завершил")||(TryRes=="pfdthibk")
{
sleep 150
sendplay r [%Tag%] Завершил дежурство на собеседовании %Frac%.{enter}
sleep 111
Gosub, razia
return
}
return

:*?:дежсобесн1::
Sendmessage, 0x50,, 0x4190419,, A
sleep 250
sendplay {esc}
sleep 111
sendplay {f8}
sleep 111
sendplay ^A{Delete}
sleep 111
sendplay, do На поясе сотрудника висит рабочая рация. {enter}
sleep 111
sendplay me сняв рацию с пояса, нажал на тангенту и что-то сказал в неё {enter}
sleep 111
sendplay выехал | прибыл | прод | завершил -->{space}
Input TryRes, V, {enter}
if(TryRes=="выехал")||(TryRes=="dst[fk")
{
sleep 150
sendplay r [%Tag%] Выехал на дежурство собеседования %Frac%. Напарник: %Partners%.{enter}
sleep 111
Gosub, razia
return
}
if(TryRes=="прибыл")||(TryRes=="ghb,sk")
{
sleep 150
sendplay r [%Tag%] Прибыл на дежурство собеседования %Frac%. Напарник: %Partners%.{enter}
sleep 111
Gosub, razia
return
}
if(TryRes=="прод")||(TryRes=="ghjl")
{
sleep 150
sendplay r [%Tag%] Продолжаю дежурство на собеседовании %Frac%. Напарник: %Partners%.{enter}
sleep 111
Gosub, razia
return
}
if(TryRes=="завершил")||(TryRes=="pfdthibk")
{
sleep 150
sendplay r [%Tag%] Завершил дежурство на собеседовании %Frac%. Напарник: %Partners%.{enter}
sleep 111
Gosub, razia
return
}
return
;________________________________________________________________________________________________________________________________________________________________________________________
:*?:дежувд1::
Sendmessage, 0x50,, 0x4190419,, A
sleep 250
sendplay {esc}
sleep 111
sendplay {f8}
sleep 111
sendplay ^A{Delete}
sleep 111
sendplay, do На поясе сотрудника висит рабочая рация. {enter}
sleep 111
sendplay me сняв рацию с пояса, нажал на тангенту и что-то сказал в неё {enter}
sleep 111
sendplay выехал | прибыл | прод | завершил -->{space}
Input TryRes, V, {enter}
if(TryRes=="выехал")||(TryRes=="dst[fk")
{
sleep 150
sendplay r [%Tag%] Выехал на дежурство в УВД-М.{enter}
sleep 111
Gosub, razia
return
}
if(TryRes=="прибыл")||(TryRes=="ghb,sk")
{
sleep 150
sendplay r [%Tag%] Прибыл на дежурство в УВД-М.{enter}
sleep 111
Gosub, razia
return
}
if(TryRes=="прод")||(TryRes=="ghjl")
{
sleep 150
sendplay r [%Tag%] Продолжаю дежурство в УВД-М.{enter}
sleep 111
Gosub, razia
return
}
if(TryRes=="завершил")||(TryRes=="pfdthibk")
{
sleep 150
sendplay r [%Tag%]  Завершил дежурство в УВД-М. Возвращаюсь в больницу. {enter}
sleep 111
Gosub, razia
return
}
return

:*?:дежувдн1::
Sendmessage, 0x50,, 0x4190419,, A
sleep 250
sendplay {esc}
sleep 111
sendplay {f8}
sleep 111
sendplay ^A{Delete}
sleep 111
sendplay, do На поясе сотрудника висит рабочая рация. {enter}
sleep 111
sendplay me сняв рацию с пояса, нажал на тангенту и что-то сказал в неё {enter}
sleep 111
sendplay выехал | прибыл | прод | завершил -->{space}
Input TryRes, V, {enter}
if(TryRes=="выехал")||(TryRes=="dst[fk")
{
sleep 150
sendplay r [%Tag%] Выехал на дежурство в УВД-М. Напарник: %Partners%.{enter}
sleep 111
Gosub, razia
return
}
if(TryRes=="прибыл")||(TryRes=="ghb,sk")
{
sleep 150
sendplay r [%Tag%] Прибыл на дежурство в УВД-М. Напарник: %Partners%.{enter}
sleep 111
Gosub, razia
return
}
if(TryRes=="прод")||(TryRes=="ghjl")
{
sleep 150
sendplay r [%Tag%] Продолжаю дежурство в УВД-М. Напарник: %Partners%.{enter}
sleep 111
Gosub, razia
return
}
if(TryRes=="завершил")||(TryRes=="pfdthibk")
{
sleep 150
sendplay r [%Tag%]  Завершил дежурство в УВД-М. Возвращаюсь в больницу.  Напарник: %Partners%.{enter}
sleep 111
Gosub, razia
return
}
return
;________________________________________________________________________________________________________________________________________________________________________________________
:*?:дежвч1::
Sendmessage, 0x50,, 0x4190419,, A
sleep 250
sendplay {esc}
sleep 111
sendplay {f8}
sleep 111
sendplay ^A{Delete}
sleep 111
sendplay, do На поясе сотрудника висит рабочая рация. {enter}
sleep 111
sendplay me сняв рацию с пояса, нажал на тангенту и что-то сказал в неё {enter}
sleep 111
sendplay выехал | прибыл | прод | завершил -->{space}
Input TryRes, V, {enter}
if(TryRes=="выехал")||(TryRes=="dst[fk")
{
sleep 150
sendplay ro [%City%] Выехал на дежурство в Воинскую часть №1017.{enter}
sleep 111
Gosub, razia
return
}
if(TryRes=="прибыл")||(TryRes=="ghb,sk")
{
sleep 150
sendplay ro [%City%] Прибыл на дежурство в Воинскую часть №1017.{enter}
sleep 111
Gosub, razia
return
}
if(TryRes=="прод")||(TryRes=="ghjl")
{
sleep 150
sendplay ro [%City%] Продолжаю дежурство в Воинской части №1017.{enter}
sleep 111
Gosub, razia
return
}
if(TryRes=="завершил")||(TryRes=="pfdthibk")
{
sleep 150
sendplay ro [%City%]  Завершил дежурство в Воинской части №1017. {enter}
sleep 111
Gosub, razia
return
}
return

:*?:дежвчн1::
Sendmessage, 0x50,, 0x4190419,, A
sleep 250
sendplay {esc}
sleep 111
sendplay {f8}
sleep 111
sendplay ^A{Delete}
sleep 111
sendplay, do На поясе сотрудника висит рабочая рация. {enter}
sleep 111
sendplay me сняв рацию с пояса, нажал на тангенту и что-то сказал в неё {enter}
sleep 111
sendplay выехал | прибыл | прод | завершил -->{space}
Input TryRes, V, {enter}
if(TryRes=="выехал")||(TryRes=="dst[fk")
{
sleep 150
sendplay ro [%City%] Выехал на дежурство в Воинскую часть №1017. Напарник: %Partners%.{enter}
sleep 111
Gosub, razia
return
}
if(TryRes=="прибыл")||(TryRes=="ghb,sk")
{
sleep 150
sendplay ro [%City%] Прибыл на дежурство в Воинскую часть №1017. Напарник: %Partners%.{enter}
sleep 111
Gosub, razia
return
}
if(TryRes=="прод")||(TryRes=="ghjl")
{
sleep 150
sendplay ro [%City%] Продолжаю дежурство в Воинской части №1017. Напарник: %Partners%.{enter}
sleep 111
Gosub, razia
return
}
if(TryRes=="завершил")||(TryRes=="pfdthibk")
{
sleep 150
sendplay ro [%City%]  Завершил дежурство в Воинской части №1017.  Напарник: %Partners%.{enter}
sleep 111
Gosub, razia
return
}
return
;________________________________________________________________________________________________________________________________________________________________________________________
:*?:собес1::
Sendmessage, 0x50,, 0x4190419,, A
sleep 250
sendplay {esc}
sleep 111
sendplay {f8}
sleep 111
sendplay ^A{Delete}
sleep 1111
sendplay say Назовите Ваше ФИО и возраст. {enter}
sleep 111
sendplay для продолжения выдачи нажмите ПРАВЫЙ CONTROL (в консоли)
keywait, RControl, D
sleep 111
sendplay ^A{Delete}
sleep 2222
sendplay say Проходили обучение в ГМИ? Имеется диплом? {enter}
sleep 333
sendplay что ответил? да | нет -->{space}
Input TryRes, V, {enter}
if(TryRes=="да")||(TryRes=="lf")
{
sleep 111
sendplay say Назовите номер и цвет диплома {enter}
sleep 111
sendplay для продолжения выдачи нажмите ПРАВЫЙ CONTROL (в консоли)
keywait, RControl, D
sleep 111
sendplay ^A{Delete}
sleep 2222
Gosub, sobes
return
}
if(TryRes=="нет")||(TryRes=="ytn")
{
sleep 1111
Gosub, sobes
return
}
return

sobes:
sendplay say Хорошо, будьте добры, передайте документы, а именно: паспорт, трудовую книгу и медицинскую карту {enter}
sleep 111
sendplay для продолжения выдачи нажмите ПРАВЫЙ CONTROL (в консоли)
keywait, RControl, D
sleep 111
sendplay ^A{Delete}
sleep 1111
sendplay say Что у меня над головой?{enter}
sleep 111
sendplay для продолжения выдачи нажмите ПРАВЫЙ CONTROL (в консоли)
keywait, RControl, D
sleep 111
sendplay ^A{Delete}
sleep 1111
sendplay say Что такое ТК, ПГ, МГ?{enter}
sleep 111
sendplay для продолжения выдачи нажмите ПРАВЫЙ CONTROL (в консоли)
keywait, RControl, D
sleep 111
sendplay ^A{Delete}
sleep 1111
sendplay b Что означает ДБ, ПГ, ТК? {enter}
sleep 111
sendplay для продолжения выдачи нажмите ПРАВЫЙ CONTROL (в консоли)
keywait, RControl, D
sleep 111
sendplay ^A{Delete}
sleep 1111
sendplay say Развернитесь спиной ко мне.{enter}
sleep 111
sendplay для продолжения выдачи нажмите ПРАВЫЙ CONTROL (в консоли)
keywait, RControl, D
sleep 111
sendplay ^A{Delete}
sleep 1111
sendplay say Что я сейчас делаю?{enter}
sleep 111
sendplay для продолжения выдачи нажмите ПРАВЫЙ CONTROL (в консоли)
keywait, RControl, D
sleep 111
sendplay ^A{Delete}
sleep 1111
sendplay say Разворачивайтесь ко мне лицом и подскажите, есть ли у вас телефон или часы?{enter}
sleep 111
sendplay для продолжения выдачи нажмите ПРАВЫЙ CONTROL (в консоли)
keywait, RControl, D
sleep 111
sendplay ^A{Delete}
sleep 1111
sendplay say Подскажите, пожалуйста, сколько сейчас времени{enter}
sleep 111
sendplay для продолжения выдачи нажмите ПРАВЫЙ CONTROL (в консоли)
keywait, RControl, D
sleep 111
sendplay ^A{Delete}
sleep 1111
sendplay say  Благодарю вас, сейчас вам передам монетку, ваша задача подкинуть её, словить и сказать что выпало{enter}
sleep 111
sendplay do Пятирублевая монета лежит в халате.{enter}
sleep 111
sendplay me достав монетку из халата, передал ее человеку напротив{enter}
sleep 111
sendplay say Приступайте{enter}
sleep 111
sendplay для продолжения выдачи нажмите ПРАВЫЙ CONTROL (в консоли)
keywait, RControl, D
sleep 111
sendplay ^A{Delete}
sleep 1111
sendplay say Как называется прибор, который висит у меня на шее?{enter}
sleep 111
sendplay для продолжения выдачи нажмите ПРАВЫЙ CONTROL (в консоли)
keywait, RControl, D
sleep 111
sendplay ^A{Delete}
sleep 1111
sendplay say Будьте добры, присядьте на одно колено.{enter}
sleep 111
sendplay для продолжения выдачи нажмите ПРАВЫЙ CONTROL (в консоли)
keywait, RControl, D
sleep 111
sendplay ^A{Delete}
sleep 1111
sendplay b Вставайте, вы прошли собеседование{enter}
sleep 111
sendplay {f8}
return

;________________________________________________________________________________________________________________________________________________________________________________________
:*?:живот1::
{
Sendmessage, 0x50,, 0x4190419,, A
sleep 250
SendPlay, Выпишу Вам Мезин. Стоимость 500 рублей. Согласны?{enter}
}
return

:*?:тошнота1::
{
Sendmessage, 0x50,, 0x4190419,, A
sleep 250
SendPlay, Выпишу Вам Церукал. Стоимость 500 рублей. Согласны?{enter}
}
return

:*?:отравление1::
{
Sendmessage, 0x50,, 0x4190419,, A
sleep 250
SendPlay, Выпишу Вам Смекта. Стоимость 500 рублей. Согласны?{enter}
}
return

:*?:ушиб1::
{
Sendmessage, 0x50,, 0x4190419,, A
sleep 250
SendPlay, Выпишу Вам Финалгон. Стоимость 500 рублей. Согласны?{enter}
}
return

:*?:обезбол1::
{
Sendmessage, 0x50,, 0x4190419,, A
sleep 250
SendPlay, Выпишу Вам Дексалгин. Стоимость 500 рублей. Согласны?{enter}
}
return

:*?:запор1::
{
Sendmessage, 0x50,, 0x4190419,, A
sleep 250
SendPlay, Выпишу Вам Гутталакс. Стоимость 500 рублей. Согласны?{enter}
}
return

:*?:понос1::
{
Sendmessage, 0x50,, 0x4190419,, A
sleep 250
SendPlay, Выпишу Вам Лоперамид. Стоимость 500 рублей. Согласны?{enter}
}
return

:*?:геморрой1::
{
Sendmessage, 0x50,, 0x4190419,, A
sleep 250
SendPlay, Выпишу Вам Релиф. Стоимость 500 рублей. Согласны?{enter}
}
return

:*?:суставы1::
{
Sendmessage, 0x50,, 0x4190419,, A
sleep 250
SendPlay, Выпишу Вам Ибупрофен. Стоимость 500 рублей. Согласны?{enter}
}
return

:*?:судороги1::
{
Sendmessage, 0x50,, 0x4190419,, A
sleep 250
SendPlay, Выпишу Вам Панангин. Стоимость 500 рублей. Согласны?{enter}
}
return

:*?:витамины1::
{
Sendmessage, 0x50,, 0x4190419,, A
sleep 250
SendPlay, Выпишу Вам Центрум. Стоимость 500 рублей. Согласны?{enter}
}
return

:*?:аллергия1::
{
Sendmessage, 0x50,, 0x4190419,, A
sleep 250
SendPlay, Выпишу Вам Супрастин. Стоимость 500 рублей. Согласны?{enter}
}
return

:*?:простуда1::
{
Sendmessage, 0x50,, 0x4190419,, A
sleep 250
SendPlay, Выпишу Вам Терафлю. Стоимость 500 рублей. Согласны?{enter}
}
return

:*?:горло1::
{
Sendmessage, 0x50,, 0x4190419,, A
sleep 250
SendPlay, Выпишу Вам Амбробене. Стоимость 500 рублей. Согласны?{enter}
}
return

:*?:насморк1::
{
Sendmessage, 0x50,, 0x4190419,, A
sleep 250
SendPlay, Выпишу Вам Отривин. Стоимость 500 рублей. Согласны?{enter}
}
return

:*?:бессонница1::
{
Sendmessage, 0x50,, 0x4190419,, A
sleep 250
SendPlay, Выпишу Вам Доксиламин. Стоимость 500 рублей. Согласны?{enter}
}
return

:*?:печень1::
{
Sendmessage, 0x50,, 0x4190419,, A
sleep 250
SendPlay, Выпишу Вам Гепатрин. Стоимость 500 рублей. Согласны?{enter}
}
return

:*?:половые1::
{
Sendmessage, 0x50,, 0x4190419,, A
sleep 250
SendPlay, Выпишу Вам Тридерм. Стоимость 500 рублей. Согласны?{enter}
}
return

:*?:сердце1::
{
Sendmessage, 0x50,, 0x4190419,, A
sleep 250
SendPlay, Выпишу Вам Валидол. Стоимость 500 рублей. Согласны?{enter}
}
return

:*?:зубы1::
{
Sendmessage, 0x50,, 0x4190419,, A
sleep 250
SendPlay, Выпишу Вам Нимесил. Стоимость 500 рублей. Согласны?{enter}
}
return

:*?:глаза1::
{
Sendmessage, 0x50,, 0x4190419,, A
sleep 250
SendPlay, Выпишу Вам Алкаин. Стоимость 500 рублей. Согласны?{enter}
}
return

:*?:ожог1::
{
Sendmessage, 0x50,, 0x4190419,, A
sleep 250
SendPlay, Выпишу Вам Пантенол. Стоимость 500 рублей. Согласны?{enter}
}
return

:*?:уши1::
{
Sendmessage, 0x50,, 0x4190419,, A
sleep 250
SendPlay, Выпишу Вам Отипакс. Стоимость 500 рублей. Согласны?{enter}
}
return

:*?:почки1::
{
Sendmessage, 0x50,, 0x4190419,, A
sleep 250
SendPlay, Выпишу Вам Нефротин. Стоимость 500 рублей. Согласны?{enter}
}
return

:*?:давление1::
{
Sendmessage, 0x50,, 0x4190419,, A
sleep 250
SendPlay, Выпишу Вам Эдарби. Стоимость 500 рублей. Согласны?{enter}
}
return

:*?:мочевой1::
{
Sendmessage, 0x50,, 0x4190419,, A
sleep 250
SendPlay, Выпишу Вам Цистерол. Стоимость 500 рублей. Согласны?{enter}
}
return

:*?:голова1::
{
Sendmessage, 0x50,, 0x4190419,, A
sleep 250
SendPlay, Выпишу Вам Миг. Стоимость 500 рублей. Согласны?{enter}
}
return

;________________________________________________________________________________________________________________________________________________________________________________________

:*?:лекдок::
{
Sendmessage, 0x50,, 0x4190419,, A
sleep 250
SendPlay, Сейчас будет проведена лекция "Уставные документы".{enter}
SendPlay, {T}
sleep 2000
SendPlay, Что такое устав? Устав — свод правил, регулирующих организацию и порядок {enter}
SendPlay, {T}
sleep 2000
SendPlay, деятельности в какой-либо определённой сфере отношений или какого-либо {enter}
SendPlay, {T}
sleep 2000
SendPlay, государственного органа, организаций, предприятия, учреждения и так далее.{enter}
SendPlay, {T}
sleep 2000
SendPlay, Каждый сотрудник нашей больницы обязан знать Устав Министерства Здравоохранения,{enter}
SendPlay, {T}
sleep 2000
SendPlay, Клятву Врача и другие важные документы, ведь они во многом помогают в работе.{enter}
SendPlay, {T}
sleep 2000
SendPlay, Зная ПоМЗ (Положение о Министерства Здравоохранения), шанс его нарушения {enter}
SendPlay, {T}
sleep 2000
SendPlay, становится гораздо ниже, чем шанс нарушения при незнании Устава.{enter}
SendPlay, {T}
sleep 2000
SendPlay, Помните: незнание уставных документов не освобождает от ответственности за {enter}
SendPlay, {T}
sleep 2000
SendPlay, нарушения. Не забывайте, сотрудники Руководящего Состава вправе выдать наказание без {enter}
SendPlay, {T}
sleep 2000
SendPlay, предупреждения, если заметят нарушение с вашей стороны.{enter}
SendPlay, {T}
sleep 2000
SendPlay, Лекция завершена.{enter}
sleep 111
sendplay {f12}
}
return

:*?:лексуб::
{
Sendmessage, 0x50,, 0x4190419,, A
sleep 250
SendPlay, Сейчас будет проведена лекция "Субординация".{enter}
SendPlay, {T}
sleep 2000
SendPlay, Субординация — система строго подчинения младших к старшим по должности, подчинённых {enter}
SendPlay, {T}
sleep 2000
SendPlay, к начальству, без какого либо исключения. Межличностные отношения сотрудников не должны {enter}
SendPlay, {T}
sleep 2000
SendPlay, влиять на рабочую обстановку в составе. Обращение к старшим на "ты", хамство, оскорбления и {enter}
SendPlay, {T}
sleep 2000
SendPlay, подобные вещи являются строго запрещенными и наказываются по ПоМЗ.{enter}
SendPlay, {T}
sleep 2000
SendPlay, Помимо коллег сотрудник обязан соблюдать субординацию с гражданскими лицами.{enter}
SendPlay, {T}
sleep 2000
SendPlay, Зная ПоМЗ (Положение о Министерства Здравоохранения), шанс его нарушения {enter}
SendPlay, {T}
sleep 2000
SendPlay, Обращение на "ты" строго запрещено. Перед началом диалога сотруднику необходимо {enter}
SendPlay, {T}
sleep 2000
SendPlay, представиться, показав бейдж. После окончания рабочего дня субординацию с гражданскими {enter}
SendPlay, {T}
sleep 2000
SendPlay, лицами и с коллегами можно не соблюдать. {enter}
SendPlay, {T}
sleep 2000
SendPlay, Лекция завершена.{enter}
sleep 111
sendplay {f12}
}
return

:*?:лекрд::
{
Sendmessage, 0x50,, 0x4190419,, A
sleep 250
SendPlay, Сейчас будет проведена лекция "Рабочий день".{enter}
SendPlay, {T}
sleep 2000
SendPlay, В нашей больнице действует определенный график рабочего дня, во время которого {enter}
SendPlay, {T}
sleep 2000
SendPlay, нахождение на смене обязательно. {enter}
SendPlay, {T}
sleep 2000
SendPlay, Понедельник - пятница — рабочий день с 10:00 до 19:00, перерыв с 13:00 до 14:00. {enter}
SendPlay, {T}
sleep 2000
SendPlay, Суббота и воскресенье — выходные дни.{enter}
SendPlay, {T}
sleep 2000
SendPlay, Помимо этого сотрудник имеет право взять дополнительный {enter}
SendPlay, {T}
sleep 2000
SendPlay, перерыв до 30 минут. Перерыв берется не чаще, чем раз в 2 часа. {enter}
SendPlay, {T}
sleep 2000
SendPlay, /b Время, указанное выше, московское. Примечание: необязательно находиться в игре на {enter}
SendPlay, {T}
sleep 2000
SendPlay, /b протяжении всего дня. В день вам нужно отыгрывать не менее 1 реальных часа (Младший {enter}
SendPlay, {T}
sleep 2000
SendPlay, /b Состав), находясь на смене. В остальное время присутствие в игре необязательно. {enter}
SendPlay, {T}
sleep 2000
SendPlay, /b Если вы отыграли дневную норму, а рабочий день не закончился, уходить со смены нельзя.{enter}
SendPlay, {T}
sleep 2000
SendPlay, При уходе со смены после рабочего дня или во время перерыва, сотрудник обязан снять {enter}
SendPlay, {T}
sleep 2000
SendPlay, рабочую форму и доложить об уходе в рацию больницы. {enter}
SendPlay, {T}
sleep 2000
SendPlay,  /b /r [ТЕГ] Сдал(а) смену. {enter}
SendPlay, {T}
sleep 2000
SendPlay, При заступлении на смену доклад в рацию также является обязательным.{enter}
SendPlay, {T}
sleep 2000
SendPlay, /b /r [ТЕГ] Заступил(а) на смену.{enter}
SendPlay, {T}
sleep 2000
SendPlay, /b Касаемо ЖА: при нахождении на смене у вас должен стоять статус !онлайн в беседе/на сайте,{enter}
SendPlay, {T}
sleep 2000
SendPlay, /b при нахождении вне смены (но на сервере, например, после рабочего дня) — !афк,{enter}
SendPlay, {T}
sleep 2000
SendPlay, /b при выходе с сервера — !вышел (оффлайн).{enter}
SendPlay, {T}
sleep 2000
SendPlay, Лекция завершена.{enter}
sleep 111
sendplay {f12}
}
return

:*?:лекрация::
{
Sendmessage, 0x50,, 0x4190419,, A
sleep 250
SendPlay, Сейчас будет проведена лекция "Рации больницы".{enter}
SendPlay, {T}
sleep 2000
SendPlay, Рация — переносное устройство, позволяющее сотрудникам, находящимся друг от друга {enter}
SendPlay, {T}
sleep 2000
SendPlay, на расстоянии, вести переговоры в режиме on-line. {enter}
SendPlay, {T}
sleep 2000
SendPlay, Основная рация нашей больницы — рация между всеми сотрудниками. В ней общение не {enter}
SendPlay, {T}
sleep 2000
SendPlay, по делу является недопустимым. Рация предназначена для докладов о своих действиях {enter}
SendPlay, {T}
sleep 2000
SendPlay, и разного рода приказов. Доклад каждого сотрудника должен быть максимально {enter}
SendPlay, {T}
sleep 2000
SendPlay, коротким и содержательным, он должен начинаться с ТЕГа сотрудника. {enter}
SendPlay, {T}
sleep 2000
SendPlay, /b Речь о RP рации (/r). Пример доклада: /r [МА] Заступил на смену. {enter}
SendPlay, {T}
sleep 2000
SendPlay, /b В данной рации запрещено флудить и общаться не по делу. (Младший {enter}
SendPlay, {T}
sleep 2000
SendPlay, /b Помимо этого, существует внутрифракционная NonRP рация (/rb). Здесь допускается {enter}
SendPlay, {T}
sleep 2000
SendPlay, /b свободное общение. Маты, оскорбления, капс и подобные вещи запрещены.{enter}
SendPlay, {T}
sleep 2000
SendPlay,  Кроме того, существует рация, которая объединяет три больницы республики. {enter}
SendPlay, {T}
sleep 2000
SendPlay, Речь идет о внутриструктурной рации, которая предназначена для особо важных докладов {enter}
SendPlay, {T}
sleep 2000
SendPlay, сотрудникам других больниц. Доклад должен начинаться с ТЕГа больницы. {enter}
SendPlay, {T}
sleep 2000
SendPlay, /b Межструктурная RP рация - /ro. Есть и NonRP рация - /rob. Сильный флуд запрещен..{enter}
SendPlay, {T}
sleep 2000
SendPlay, /b Пример доклада: /r [ЦГБ-Н] Требуется помощь в госпитализации пациента.{enter}
SendPlay, {T}
sleep 2000
SendPlay, Лекция завершена.{enter}
sleep 111
sendplay {f12}
}
return

:*?:лекксмп::
{
Sendmessage, 0x50,, 0x4190419,, A
sleep 250
SendPlay, Сейчас будет проведена лекция "Карета СМП".{enter}
SendPlay, {T}
sleep 2000
SendPlay, Карета Скорой Медицинской Помощи — служебный автомобиль, находящийся в собственности {enter}
SendPlay, {T}
sleep 2000
SendPlay, больницы, используемый для госпитализации пациентов и патрулирования города. {enter}
SendPlay, {T}
sleep 2000
SendPlay, Использование кареты СМП разрешено с должности фельдшера. При взятии кареты для работые {enter}
SendPlay, {T}
sleep 2000
SendPlay, сотрудник обязан сделать доклад в рацию в зависимости от цели. {enter}
SendPlay, {T}
sleep 2000
SendPlay, /b Цели — вызов, патрулирование, стоянка на посту. Доклады есть на городском портале. {enter}
SendPlay, {T}
sleep 2000
SendPlay, /b Один из примеров: /r [ТЕГ] Принял вызов №3-1-2. {enter}
SendPlay, {T}
sleep 2000
SendPlay, Использование кареты СМП в личных целях строго запрещено. При использовании кареты {enter}
SendPlay, {T}
sleep 2000
SendPlay, сотрудник обязан соблюдать ПДД (исключение - вызов). {enter}
SendPlay, {T}
sleep 2000
SendPlay, Лекция завершена.{enter}
sleep 111
sendplay {f12}
}
return

:*?:лексобес::
{
Sendmessage, 0x50,, 0x4190419,, A
sleep 250
SendPlay, Сейчас будет проведена лекция "Дежурство на собеседованиях".{enter}
SendPlay, {T}
sleep 2000
SendPlay, Дежурство на собеседованиях — слежка за обстановкой на собеседовании какой-либо {enter}
SendPlay, {T}
sleep 2000
SendPlay, организации. Дежурство осуществляется на карете СМП. Для начала дежурства {enter}
SendPlay, {T}
sleep 2000
SendPlay, сотрудник должен дождаться запроса о помощи медицинских работников в дежурстве от {enter}
SendPlay, {T}
sleep 2000
SendPlay, организации, в которую проводится собеседование. {enter}
SendPlay, {T}
sleep 2000
SendPlay, При отсутствии подобного запроса вызов на дежурство невозможен. {enter}
SendPlay, {T}
sleep 2000
SendPlay, После успешного выезда на дежурство сотрудник должен внимательно контролировать {enter}
SendPlay, {T}
sleep 2000
SendPlay, обстановку на собеседовании, лечить нуждающихся в помощи граждан и оказывать первую {enter}
SendPlay, {T}
sleep 2000
SendPlay, медицинскую помощь в случае чрезвычайной ситуации. На протяжении всего дежурства {enter}
SendPlay, {T}
sleep 2000
SendPlay, сотрудник обязан делать доклады в рацию каждые 10 минут. После окончания собеседования {enter}
SendPlay, {T}
sleep 2000
SendPlay, дежурство должно завершиться. {enter}
SendPlay, {T}
sleep 2000
SendPlay, /b Пример доклада: /r [ТЕГ] Продолжаю дежурство на собеседовании.{enter}
SendPlay, {T}
sleep 2000
SendPlay, Лекция завершена.{enter}
sleep 111
sendplay {f12}
}
return

:*?:леккаш::
{
Sendmessage, 0x50,, 0x4190419,, A
sleep 250
SendPlay, Сейчас будет проведена лекция "Кашель".{enter}
SendPlay, {T}
sleep 2000
SendPlay, Кашель — это защитная реакция организма, созданная для очищения органов дыхания от {enter}
SendPlay, {T}
sleep 2000
SendPlay, опасных агентов. Пусковым механизмом является раздражение кашлевых рецепторов. Эти {enter}
SendPlay, {T}
sleep 2000
SendPlay, рецепторы расположены как в органах, связанных с дыханием (нос, придаточные пазухи, {enter}
SendPlay, {T}
sleep 2000
SendPlay, глотка, гортань, трахея, бронхи, плевра), так и за пределами дыхательных путей (в ушном {enter}
SendPlay, {T}
sleep 2000
SendPlay, канале, в желудке, в диафрагме). Причины кашля могут быть самыми разными. {enter}
SendPlay, {T}
sleep 2000
SendPlay, Для быстрого лечения кашля следует пить травяные отвары и делать ингаляции. Помочь могут {enter}
SendPlay, {T}
sleep 2000
SendPlay, мёд с молоком и содой, лук с мёдом, пары вареной картошки или риса и подобные способы. {enter}
SendPlay, {T}
sleep 2000
SendPlay, Помимо этого, лечение кашля возможно и лекарственными средствами, например, с помощью {enter}
SendPlay, {T}
sleep 2000
SendPlay, АЦЦ или Мукалтина.{enter}
SendPlay, {T}
sleep 2000
SendPlay, Лекция завершена.{enter}
sleep 111
sendplay {f12}
}
return

:*?:лекорг::
{
Sendmessage, 0x50,, 0x4190419,, A
sleep 250
SendPlay, Сейчас будет проведена лекция "Организм".{enter}
SendPlay, {T}
sleep 2000
SendPlay, Организм — живое тело, обладающее совокупностью свойств, отличающих его от неживой {enter}
SendPlay, {T}
sleep 2000
SendPlay, материи, в том числе обменом веществ, самоподдерживанием своего строения и организации, {enter}
SendPlay, {T}
sleep 2000
SendPlay, способностью воспроизводить их при размножении, сохраняя наследственные признаки {enter}
SendPlay, {T}
sleep 2000
SendPlay, Термин "организм" введён Аристотелем. Он выявил, что любое живое существо характеризуется {enter}
SendPlay, {T}
sleep 2000
SendPlay, четкой и строгой организацией, в отличие от неживого. Может рассматриваться как отдельная {enter}
SendPlay, {T}
sleep 2000
SendPlay, особь, элемент, при этом входя в биологический вид и популяцию, являясь структурной единицей {enter}
SendPlay, {T}
sleep 2000
SendPlay, популяционно-видового уровня жизни. В обобщённом смысле, как «типовая особь» {enter}
SendPlay, {T}
sleep 2000
SendPlay, биологической группы, которой присущи её основные свойства, организм — один из главных {enter}
SendPlay, {T}
sleep 2000
SendPlay, предметов изучения в биологии. Для удобства рассмотрения все организмы распределяются по {enter}
SendPlay, {T}
sleep 2000
SendPlay, разным группам и категориям, что составляет биологическую систему их классификации. Самое {enter}
SendPlay, {T}
sleep 2000
SendPlay, общее их деление — на ядерные и безъядерные. По числу составляющих организм клеток их делят{enter}
SendPlay, {T}
sleep 2000
SendPlay, на внесистематические категории одноклеточных и многоклеточных. Особое место между ними {enter}
SendPlay, {T}
sleep 2000
SendPlay, занимают колонии одноклеточных.{enter}
SendPlay, {T}
sleep 2000
SendPlay, Лекция завершена.{enter}
sleep 111
sendplay {f12}
}
return

:*?:лекскелет::
{
Sendmessage, 0x50,, 0x4190419,, A
sleep 250
SendPlay, Сейчас будет проведена лекция "Скелет человека".{enter}
SendPlay, {T}
sleep 2000
SendPlay, Скелет человека — совокупность костей человеческого организма, пассивная часть {enter}
SendPlay, {T}
sleep 2000
SendPlay, опорно-двигательного аппарата. Служит опорой мягким тканям, точкой приложения мышц, {enter}
SendPlay, {T}
sleep 2000
SendPlay, вместилищем и защитой внутренних органов. Костная ткань скелета развивается из мезенхимы.  {enter}
SendPlay, {T}
sleep 2000
SendPlay, Скелет взрослого человека состоит из 206 костей. Почти все они объединяются в единое целое {enter}
SendPlay, {T}
sleep 2000
SendPlay, с помощью суставов, связок и других соединений. При рождении человеческий скелет состоит {enter}
SendPlay, {T}
sleep 2000
SendPlay, из 270 костей. Число костей в зрелом возрасте снижается до 206, так как некоторые кости {enter}
SendPlay, {T}
sleep 2000
SendPlay, срастаются вместе. Преимущественно срастаются кости черепа, таза и позвоночника. {enter}
SendPlay, {T}
sleep 2000
SendPlay, Лекция завершена.{enter}
sleep 111
sendplay {f12}
}
return

:*?:леклей::
{
Sendmessage, 0x50,, 0x4190419,, A
sleep 250
SendPlay, Сейчас будет проведена лекция "Лейкоциты".{enter}
SendPlay, {T}
sleep 2000
SendPlay, Лейкоциты — белые кровяные клетки; неоднородная группа различных по внешнему виду {enter}
SendPlay, {T}
sleep 2000
SendPlay, и функциям клеток крови человека или животных, выделенная по признакам наличия ядра и {enter}
SendPlay, {T}
sleep 2000
SendPlay, отсутствия самостоятельной окраски. Главная сфера действия лейкоцитов — защита.  {enter}
SendPlay, {T}
sleep 2000
SendPlay, Они играют главную роль в специфической и неспецифической защите организма от внешних {enter}
SendPlay, {T}
sleep 2000
SendPlay,  и внутренних патогенных агентов, а также в реализации типичных патологических процессов.  {enter}
SendPlay, {T}
sleep 2000
SendPlay, Все виды лейкоцитов способны к активному движению и могут переходить через стенку {enter}
SendPlay, {T}
sleep 2000
SendPlay,  капилляров и проникать в межклеточное пространство, где они поглощают и переваривают {enter}
SendPlay, {T}
sleep 2000
SendPlay, чужеродные частицы. Этот процесс называется фагоцитоз, а клетки, его осуществляющие,{enter}
SendPlay, {T}
sleep 2000
SendPlay, — фагоциты. {enter}
SendPlay, {T}
sleep 2000
SendPlay, Лекция завершена.{enter}
sleep 111
sendplay {f12}
}
return

:*?:лексон::
{
Sendmessage, 0x50,, 0x4190419,, A
sleep 250
SendPlay, Сейчас будет проведена лекция "Сон".{enter}
SendPlay, {T}
sleep 2000
SendPlay, Сон — периодически возникающее физиологическое состояние, противоположное состоянию {enter}
SendPlay, {T}
sleep 2000
SendPlay, бодрствования, характеризующееся пониженной реакцией на окружающий мир, присущее {enter}
SendPlay, {T}
sleep 2000
SendPlay, млекопитающим, птицам, рыбам и некоторым другим животным, в том числе насекомым.  {enter}
SendPlay, {T}
sleep 2000
SendPlay, Помимо этого, словом «сон» называют последовательность образов (формируемых в течение {enter}
SendPlay, {T}
sleep 2000
SendPlay,  фазы т. н. «быстрого сна»), которые человек может помнить, — сновидение. Физиологически  {enter}
SendPlay, {T}
sleep 2000
SendPlay, обычный сон отличается от других, похожих на него состояний — анабиоза и спячки у животных, {enter}
SendPlay, {T}
sleep 2000
SendPlay,  гипнотического сна, комы, обморока, летаргического сна. Сну предшествует процесс перехода {enter}
SendPlay, {T}
sleep 2000
SendPlay, от бодрствования — засыпание, заканчивается сон пробуждением.{enter}
SendPlay, {T}
sleep 2000
SendPlay, Лекция завершена.{enter}
sleep 111
sendplay {f12}
}
return

:*?:лекпеч::
{
Sendmessage, 0x50,, 0x4190419,, A
sleep 250
SendPlay, Сейчас будет проведена лекция "Печень".{enter}
SendPlay, {T}
sleep 2000
SendPlay, Печень — жизненно важная железа внешней секреции позвоночных животных, в том числе {enter}
SendPlay, {T}
sleep 2000
SendPlay, и человека, находящаяся в брюшной полости (полости живота) под диафрагмой и выполняющая {enter}
SendPlay, {T}
sleep 2000
SendPlay, большое количество различных физиологических функций. Печень является самой крупной  {enter}
SendPlay, {T}
sleep 2000
SendPlay, железой позвоночных. Печень состоит из двух долей: правой и левой. В правой доле выделяют {enter}
SendPlay, {T}
sleep 2000
SendPlay,  ещё две вторичные доли: квадратную и хвостатую. По современной сегментарной схеме  {enter}
SendPlay, {T}
sleep 2000
SendPlay, печень разделяется на восемь сегментов, образующих правую и левую доли. {enter}
SendPlay, {T}
sleep 2000
SendPlay, Лекция завершена.{enter}
sleep 111
sendplay {f12}
}
return

:*?:лекмаз::
{
Sendmessage, 0x50,, 0x4190419,, A
sleep 250
SendPlay, Сейчас будет проведена лекция "Появление мозолей".{enter}
SendPlay, {T}
sleep 2000
SendPlay, Кожная мозоль — результат продолжительного трения или давления на кожу. {enter}
SendPlay, {T}
sleep 2000
SendPlay, Проявляется в виде ороговевших областей (омертвение клеток эпителия) — сухая мозоль; {enter}
SendPlay, {T}
sleep 2000
SendPlay,  или мозольного пузыря, содержащего тканевую жидкость в верхних слоях кожи — мокрая  {enter}
SendPlay, {T}
sleep 2000
SendPlay, мозоль. Жидкость собирается под повреждённым слоем кожи, защищая её от дальнейших {enter}
SendPlay, {T}
sleep 2000
SendPlay,  повреждений и позволяя ей залечиться. Подобный пузырь появляется, как правило, когда  {enter}
SendPlay, {T}
sleep 2000
SendPlay, кровеносные сосуды расположены близко к поверхности кожи в месте образования мозоли, а кожа {enter}
SendPlay, {T}
sleep 2000
SendPlay, подверглась очень большому по силе трению или давлению. Чаще всего мозоли появляются на {enter}
SendPlay, {T}
sleep 2000
SendPlay, стопах от тесной обуви и на руках от работы.{enter}
SendPlay, {T}
sleep 2000
SendPlay, Лекция завершена.{enter}
sleep 111
sendplay {f12}
}
return

:*?:леккамн::
{
Sendmessage, 0x50,, 0x4190419,, A
sleep 250
SendPlay, Сейчас будет проведена лекция "Появление камней в почках".{enter}
SendPlay, {T}
sleep 2000
SendPlay, Камни в почках (почечный литоизм, нефролитиаз) представляют собой твердые отложения из {enter}
SendPlay, {T}
sleep 2000
SendPlay, минералов и солей, которые образуются внутри почек. Камни в почках имеют много причин и {enter}
SendPlay, {T}
sleep 2000
SendPlay,  могут влиять на любую часть мочевого тракта — от почек до мочевого пузыря. Часто образуются  {enter}
SendPlay, {T}
sleep 2000
SendPlay, камни, когда моча концентрируется, позволяя минералам кристаллизоваться и склеиваться {enter}
SendPlay, {T}
sleep 2000
SendPlay,  Прохождение камней в почках может быть довольно болезненным, но камни обычно не наносят  {enter}
SendPlay, {T}
sleep 2000
SendPlay, постоянного повреждения, если они распознаются своевременно. В зависимости от ситуации вам {enter}
SendPlay, {T}
sleep 2000
SendPlay, может понадобиться не больше, чем принимать обезболивающие средства и пить много воды, {enter}
SendPlay, {T}
sleep 2000
SendPlay, чтобы пройти почечный камень. В других случаях, например, если камни попадают в {enter}
SendPlay, {T}
sleep 2000
SendPlay, мочевыводящих путей, они связаны с инфекцией мочевыводящих путей или вызывают {enter}
SendPlay, {T}
sleep 2000
SendPlay, осложнения, может потребоваться хирургическое вмешательство.{enter}
SendPlay, {T}
sleep 2000
SendPlay, Лекция завершена.{enter}
sleep 111
sendplay {f12}
}
return

:*?:лекволос::
{
Sendmessage, 0x50,, 0x4190419,, A
sleep 250
SendPlay, Сейчас будет проведена лекция "Волосы на человеческом теле".{enter}
SendPlay, {T}
sleep 2000
SendPlay, Все тело человека еще до его рождения покрыто мелкими волосками, которые растут и постоянно {enter}
SendPlay, {T}
sleep 2000
SendPlay, заменяются. Они способны в холод согревать организм, а в жару, наоборот, охлаждать, поглощая {enter}
SendPlay, {T}
sleep 2000
SendPlay,   излишнюю влагу. Ответ на вопрос, зачем человеку волосы, не может быть однозначен. К примеру,  {enter}
SendPlay, {T}
sleep 2000
SendPlay, волосяной покров у человека на голове, как думают многие, выполняет эстетическую функцию. {enter}
SendPlay, {T}
sleep 2000
SendPlay,  защита головного мозга от низкой и высокой температуры воздуха в холод и в жару. Также  {enter}
SendPlay, {T}
sleep 2000
SendPlay, волосяной покров на голове защищает черепную коробку от мелких механических травм. {enter}
SendPlay, {T}
sleep 2000
SendPlay, По мнению ученых, растительность на теле человека имеет несколько причин. Первая из {enter}
SendPlay, {T}
sleep 2000
SendPlay, них — климат. Наши предки имели волосяной покров в виде густой шерсти. Со временем {enter}
SendPlay, {T}
sleep 2000
SendPlay, он становился все реже и менее выразительным. Некоторые ученые утверждают, что виной {enter}
SendPlay, {T}
sleep 2000
SendPlay, тому стал жаркий климат. Именно из-за него происходила «линька». Также важной функцией {enter}
SendPlay, {T}
sleep 2000
SendPlay, покрова из мелких волосков является защита тела от паразитов и насекомых. Они помогают {enter}
SendPlay, {T}
sleep 2000
SendPlay, задержать вредителя на поверхности тела до того, как он начнет «атаку».{enter}
SendPlay, {T}
sleep 2000
SendPlay, Лекция завершена.{enter}
sleep 111
sendplay {f12}
}
return

:*?:лекпатр::
{
Sendmessage, 0x50,, 0x4190419,, A
sleep 250
SendPlay, Сейчас будет проведена лекция "Патрулирование".{enter}
SendPlay, {T}
sleep 2000
SendPlay, Патрулирование — езда по городу и области для контроля обстановки, лечения {enter}
SendPlay, {T}
sleep 2000
SendPlay, пострадавших граждан и для остановки на ДТП, встречающихся на пути. {enter}
SendPlay, {T}
sleep 2000
SendPlay,   Патрулирование осуществляется на карете СМП или на медицинском вертолете (со старшего  {enter}
SendPlay, {T}
sleep 2000
SendPlay, специалиста). Во всех больницах нашей Республики патрулирование осуществляется в свободном {enter}
SendPlay, {T}
sleep 2000
SendPlay,  режиме. Во время патруля запрещено нарушать правила дорожного движения. Каждые  {enter}
SendPlay, {T}
sleep 2000
SendPlay, 10 минут от сотрудника должны поступать доклады в рацию, сообщающие обстановку {enter}
SendPlay, {T}
sleep 2000
SendPlay, на местности. Во время патрулирования разрешено принимать вызовы. {enter}
SendPlay, {T}
sleep 2000
SendPlay, Лекция завершена.{enter}
sleep 111
sendplay {f12}
}
return

:*?:лекпост::
{
Sendmessage, 0x50,, 0x4190419,, A
sleep 250
SendPlay, Сейчас будет проведена лекция "Дежурство на посту".{enter}
SendPlay, {T}
sleep 2000
SendPlay, Пост — дежурство на определенной местности для контроля обстановки и оказания медицинской {enter}
SendPlay, {T}
sleep 2000
SendPlay, помощи в случае чрезвычайных ситуаций. Стоянка на посту осуществляется на карете СМП {enter}
SendPlay, {T}
sleep 2000
SendPlay, или на медицинском вертолете. Во всех больницах существует нумерация постов во избежание путаницы.{enter}
SendPlay, {T}
sleep 2000
SendPlay,  Во время стоянки на посту сотрудник обязан делать доклады {enter}
SendPlay, {T}
sleep 2000
SendPlay,  в рацию об обстановке на местности каждые 10 минут. {enter}
SendPlay, {T}
sleep 2000
SendPlay, Вызовы принимать разрешено. {enter}
SendPlay, {T}
sleep 2000
SendPlay, Лекция завершена.{enter}
sleep 111
sendplay {f12}
}
return

:*?:лекверт::
{
Sendmessage, 0x50,, 0x4190419,, A
sleep 250
SendPlay, Сейчас будет проведена лекция "Медицинский вертолёт".{enter}
SendPlay, {T}
sleep 2000
SendPlay, Медицинский вертолет — особый вид рабочего транспорта, предназначенный для {enter}
SendPlay, {T}
sleep 2000
SendPlay, госпитализации пациентов с особо тяжелыми травмами и для обработки вызовов из {enter}
SendPlay, {T}
sleep 2000
SendPlay,  труднодоступных мест города. Медицинский вертолет можно брать сотрудникам,{enter}
SendPlay, {T}
sleep 2000
SendPlay,  достигшим должности врача-хирурга и выше. Напарником может быть любой сотрудник, {enter}
SendPlay, {T}
sleep 2000
SendPlay,  достигший должности врач-стажер. {enter}
SendPlay, {T}
sleep 2000
SendPlay, На одну организацию положен лишь один вертолет, {enter}
SendPlay, {T}
sleep 2000
SendPlay,  брать который можно для обработки срочных вызовов из труднодоступных мест города,{enter}
SendPlay, {T}
sleep 2000
SendPlay, воздушного патрулирования или для стоянки на вертолетных постах.{enter}
SendPlay, {T}
sleep 2000
SendPlay, В вертолете, как и в карете СМП, имеется одна кушетка для пациента.{enter}
SendPlay, {T}
sleep 2000
SendPlay, В темное время суток можно включить яркий фонарь для поиска пострадавшего.{enter}
SendPlay, {T}
sleep 2000
SendPlay, Лекция завершена.{enter}
sleep 111
sendplay {f12}
}
return

:*?:лекокров::
{
Sendmessage, 0x50,, 0x4190419,, A
sleep 250
SendPlay, Сейчас будет проведена лекция "Остановка крови".{enter}
SendPlay, {T}
sleep 2000
SendPlay, В остановке крови, стекающей с небольшого пореза, вам поможет простая вода. Для этого нужно {enter}
SendPlay, {T}
sleep 2000
SendPlay, направить струю холодной воды на порез. Благодаря этому сосуды сократятся, а кровь остановится. {enter}
SendPlay, {T}
sleep 2000
SendPlay,  Почистив рану, оказывайте давление на нее марлей или салфеткой до тех пор, пока кровь {enter}
SendPlay, {T}
sleep 2000
SendPlay,  окончательно не остановится. В остановке крови так же может помочь Вазелин. Он заблокирует {enter}
SendPlay, {T}
sleep 2000
SendPlay,  путь крови и даст время свернуться. После остановки кровотечения необходимо забинтовать {enter}
SendPlay, {T}
sleep 2000
SendPlay, рану для того, чтобы избежать попадания лишних бактерий и предотвратить дальнейшую, {enter}
SendPlay, {T}
sleep 2000
SendPlay,  вытечку крови.{enter}
SendPlay, {T}
sleep 2000
SendPlay, Лекция завершена.{enter}
sleep 111
sendplay {f12}
}
return

:*?:лекпук::
{
Sendmessage, 0x50,, 0x4190419,, A
sleep 250
SendPlay, Сейчас будет проведена лекция "Пупок".{enter}
SendPlay, {T}
sleep 2000
SendPlay, Пупок — рубец на передней брюшной стенке, остающийся после удаления пуповины у {enter}
SendPlay, {T}
sleep 2000
SendPlay, новорождённого ребёнка. Пупком обладают все плацентарные млекопитающие, у большинства из {enter}
SendPlay, {T}
sleep 2000
SendPlay, которых он выглядит небольшой линией без волосяного покрова. У части людей пупок выглядит {enter}
SendPlay, {T}
sleep 2000
SendPlay,  как углубление в кожном покрове, у других, напротив, как выпуклость. Помимо этого, пупки {enter}
SendPlay, {T}
sleep 2000
SendPlay,  различаются по размерам, форме, глубине и т. д. Во время внутриутробного развития через пупок {enter}
SendPlay, {T}
sleep 2000
SendPlay, проходят две пупочные артерии и одна вена. После рождения вена зарастает и превращается в {enter}
SendPlay, {T}
sleep 2000
SendPlay,  круглую связку печени. Пупок используется для визуального разделения живота на сектора.{enter}
SendPlay, {T}
sleep 2000
SendPlay, У разных людей высота расположения пупка может отличаться, однако «Божественные {enter}
SendPlay, {T}
sleep 2000
SendPlay, пропорции», основанные на Золотом сечении, предполагают его расположение на 62 процента высоты, {enter}
SendPlay, {T}
sleep 2000
SendPlay, тела. Для изменения формы пупка можно провести пластическую операцию — умбиликопластику.{enter}
SendPlay, {T}
sleep 2000
SendPlay, Лекция завершена.{enter}
sleep 111
sendplay {f12}
}
return

:*?:лекнар::
{
Sendmessage, 0x50,, 0x4190419,, A
sleep 250
SendPlay, Сейчас будет проведена лекция "Наркотики".{enter}
SendPlay, {T}
sleep 2000
SendPlay, Наркотики — это химические вещества растительного или синтетического происхождения, {enter}
SendPlay, {T}
sleep 2000
SendPlay, способные вызывать изменение психического состояния, систематическое применение которых {enter}
SendPlay, {T}
sleep 2000
SendPlay, приводит к зависимости. Наркомания — заболевание, обусловленное зависимостью от {enter}
SendPlay, {T}
sleep 2000
SendPlay, наркотического средства или психотропного вещества. В результате употребления наркотиков {enter}
SendPlay, {T}
sleep 2000
SendPlay, формируется психическая и физическая зависимость. Скорость формирования зависимости и ее {enter}
SendPlay, {T}
sleep 2000
SendPlay, тяжесть могут быть разными: влияет возраст, частота употребления, особенности организма. {enter}
SendPlay, {T}
sleep 2000
SendPlay,  Состояние психической зависимости проявляется в том, что человек с помощью наркотика желает {enter}
SendPlay, {T}
sleep 2000
SendPlay, добиться внутреннего равновесия и стремится вновь и вновь испытать действие наркотика. {enter}
SendPlay, {T}
sleep 2000
SendPlay, Наркотик, его действие постепенно замещает собой все обычные для человека положительные {enter}
SendPlay, {T}
sleep 2000
SendPlay, эмоции. Опыты на животных показали, что даже при недолговременном употреблении наркотики {enter}
SendPlay, {T}
sleep 2000
SendPlay, убивают клетки головного мозга, вырабатывающие серотонин — вещество, с помощью которого {enter}
SendPlay, {T}
sleep 2000
SendPlay, мозг контролирует перепады настроения.{enter}
SendPlay, {T}
sleep 2000
SendPlay, Лекция завершена.{enter}
sleep 111
sendplay {f12}
}
return

:*?:лексос::
{
Sendmessage, 0x50,, 0x4190419,, A
sleep 250
SendPlay, Сейчас будет проведена лекция "Кровеносные сосуды".{enter}
SendPlay, {T}
sleep 2000
SendPlay, Кровеносные сосуды — эластичные трубчатые образования в теле животных, по которым силой {enter}
SendPlay, {T}
sleep 2000
SendPlay, ритмически сокращающегося сердца или пульсирующего сосуда осуществляется перемещение {enter}
SendPlay, {T}
sleep 2000
SendPlay, крови по организму: к органам и тканям по артериям, артериолам, капиллярам, и от них к сердцу {enter}
SendPlay, {T}
sleep 2000
SendPlay, — по венулам и венам. Среди сосудов кровеносной системы различают артерии, вены и сосуды {enter}
SendPlay, {T}
sleep 2000
SendPlay, системы микроциркуляторного русла; последние осуществляют взаимосвязь между артериями {enter}
SendPlay, {T}
sleep 2000
SendPlay, и венами и включают, в свою очередь, артериолы, капилляры, венулы и артериоло-венулярные {enter}
SendPlay, {T}
sleep 2000
SendPlay,  анастомозы. Сосуды разных типов отличаются не только по своему диаметру, но также по {enter}
SendPlay, {T}
sleep 2000
SendPlay, тканевому составу и функциональным особенностям.  {enter}
SendPlay, {T}
sleep 2000
SendPlay, Лекция завершена.{enter}
sleep 111
sendplay {f12}
}
return

:*?:лексер::
{
Sendmessage, 0x50,, 0x4190419,, A
sleep 250
SendPlay, Сейчас будет проведена лекция "Сердце".{enter}
SendPlay, {T}
sleep 2000
SendPlay, Сердце — полый фиброзно-мышечный орган, обеспечивающий посредством повторных {enter}
SendPlay, {T}
sleep 2000
SendPlay, ритмичных сокращений ток крови по кровеносным сосудам. Присутствует у всех живых {enter}
SendPlay, {T}
sleep 2000
SendPlay, организмов с развитой кровеносной системой, включая всех позвоночных, в том числе и {enter}
SendPlay, {T}
sleep 2000
SendPlay, человека. Сердце позвоночных состоит главным образом из сердечной, эндотелиальной и {enter}
SendPlay, {T}
sleep 2000
SendPlay, соединительной ткани. При этом сердечная мышца представляет собой особый вид  {enter}
SendPlay, {T}
sleep 2000
SendPlay, поперечно-полосатой мышечной ткани, встречающейся исключительно в сердце. Сердце {enter}
SendPlay, {T}
sleep 2000
SendPlay,  человека, сокращаясь в среднем 72 раза в минуту, на протяжении 66 лет совершит около 2,5 {enter}
SendPlay, {T}
sleep 2000
SendPlay, миллиардов сердечных циклов. Масса сердца у человека зависит от пола и обычно достигает {enter}
SendPlay, {T}
sleep 2000
SendPlay, 250—320 граммов у женщин и 300—360 граммов у мужчин. {enter}
SendPlay, {T}
sleep 2000
SendPlay, Лекция завершена.{enter}
sleep 111
sendplay {f12}
}
return

:*?:леквыз::
{
Sendmessage, 0x50,, 0x4190419,, A
sleep 250
SendPlay, Сейчас будет проведена лекция "Обработка вызова".{enter}
SendPlay, {T}
sleep 2000
SendPlay,  После поступления вызова в больницу сотрудник должен принять его, сделав соответствующий {enter}
SendPlay, {T}
sleep 2000
SendPlay, доклад в рацию. {enter}
SendPlay, {T}
sleep 2000
SendPlay, /b Пример: /r [ТЕГ] Принял вызов №3-1-2. Доклады есть на форуме. {enter}
SendPlay, {T}
sleep 2000
SendPlay, После доклада в рацию сотрудник должен отправиться на место вызова на карете СМП или на {enter}
SendPlay, {T}
sleep 2000
SendPlay, медицинском вертолете (при острой необходимости). По прибытии на место вызова и после {enter}
SendPlay, {T}
sleep 2000
SendPlay, соответствующего доклада в рацию сотрудник должен погрузить пострадавшего на кушетку {enter}
SendPlay, {T}
sleep 2000
SendPlay,  (если ему очень плохо) и увезти в больницу или вылечить пациента на месте, дав ему {enter}
SendPlay, {T}
sleep 2000
SendPlay, лекарство в карете СМП. {enter}
SendPlay, {T}
sleep 2000
SendPlay, Когда сотрудник с пострадавшим прибыл в больницу, он должен выгрузить кушетку. {enter}
SendPlay, {T}
sleep 2000
SendPlay, /b Обязательно прожав 2 бинда о вызове дежурного врача и нажать R {enter}
SendPlay, {T}
sleep 2000
SendPlay,  Дальнейшее лечение в обработку вызова не входит.{enter}
SendPlay, {T}
sleep 2000
SendPlay, Лекция завершена.{enter}
sleep 111
sendplay {f12}
}
return

:*?:лекаллерг::
{
Sendmessage, 0x50,, 0x4190419,, A
sleep 250
SendPlay, Сейчас будет проведена лекция "Аллергия".{enter}
SendPlay, {T}
sleep 2000
SendPlay,  Аллергия — состояние организма, при котором иммунная система видит угрозу {enter}
SendPlay, {T}
sleep 2000
SendPlay, в веществах, на самом деле не представляющих опасность для человека. Иммунитет считает {enter}
SendPlay, {T}
sleep 2000
SendPlay, их антигенами, поэтому начинает вырабатывать против них антитела. В этот период человек {enter}
SendPlay, {T}
sleep 2000
SendPlay,  и начинает ощущать, что организм борется с болезнью, что проявляется неприятными {enter}
SendPlay, {T}
sleep 2000
SendPlay,  симптомами. В реальности же настоящих возбудителей болезни нет. Такая повышенная {enter}
SendPlay, {T}
sleep 2000
SendPlay, чувствительность организма к отдельным веществам (аллергенам) и называется аллергией. {enter}
SendPlay, {T}
sleep 2000
SendPlay,  Основным методом лечения аллергии является соблюдение особого питания. Именно это {enter}
SendPlay, {T}
sleep 2000
SendPlay, позволяет избавиться от неприятных симптомов и свести к минимуму риск рецидивов. Диета {enter}
SendPlay, {T}
sleep 2000
SendPlay, аллергии соблюдается пожизненно, поскольку это заболевание хроническое. Она требует {enter}
SendPlay, {T}
sleep 2000
SendPlay, полного исключения из рациона тех продуктов, которые провоцируют возникновение {enter}
SendPlay, {T}
sleep 2000
SendPlay,  ее признаков. Дополнительно сегодня практикуются и другие методы лечения: {enter}
SendPlay, {T}
sleep 2000
SendPlay, внутривенное лазерное облучение крови. Дает иммуноукрепляющий и противовоспалительный {enter}
SendPlay, {T}
sleep 2000
SendPlay, эффекты; аллерген-специфическая иммунотерапия. В организм вводят аллерген, дозу которого {enter}
SendPlay, {T}
sleep 2000
SendPlay, постепенно увеличивают, чтобы снизить чувствительность к нему организма.{enter}
SendPlay, {T}
sleep 2000
SendPlay, Лекция завершена.{enter}
sleep 111
sendplay {f12}
}
return

:*?:лекчих::
{
Sendmessage, 0x50,, 0x4190419,, A
sleep 250
SendPlay, Сейчас будет проведена лекция "Причины чихания".{enter}
SendPlay, {T}
sleep 2000
SendPlay,  Чих — это один из защитных механизмов организма, который позволяет избавиться от {enter}
SendPlay, {T}
sleep 2000
SendPlay, посторонних организмов и спасает лёгкие и другие органы от загрязнения. Спровоцировать чих {enter}
SendPlay, {T}
sleep 2000
SendPlay, могут многие факторы. Это и банальная простуда, и аллергия, и грязный воздух, и физические {enter}
SendPlay, {T}
sleep 2000
SendPlay, раздражители, такие, как пыль, холодный воздух или яркое солнце. Процесс чиханья начинается {enter}
SendPlay, {T}
sleep 2000
SendPlay, с раздражения дыхательного эпителия, который с помощью тройничного нерва подаёт мозгу {enter}
SendPlay, {T}
sleep 2000
SendPlay, сигнал о необходимости прочистить носоглотку. Интересный факт: при чихе воздух вылетает {enter}
SendPlay, {T}
sleep 2000
SendPlay,  из нашего носа со скоростью 150 километров в час. {enter}
SendPlay, {T}
sleep 2000
SendPlay, Лекция завершена.{enter}
sleep 111
sendplay {f12}
}
return

:*?:леккров::
{
Sendmessage, 0x50,, 0x4190419,, A
sleep 250
SendPlay, Сейчас будет проведена лекция "Кровь".{enter}
SendPlay, {T}
sleep 2000
SendPlay,  Кровь — жидкая и подвижная соединительная ткань внутренней среды организма.  {enter}
SendPlay, {T}
sleep 2000
SendPlay, Состоит из жидкой среды — плазмы — и взвешенных в ней форменных элементов  {enter}
SendPlay, {T}
sleep 2000
SendPlay, (клеток и производных от клеток): эритроцитов, лейкоцитов и тромбоцитов. Циркулирует по {enter}
SendPlay, {T}
sleep 2000
SendPlay, замкнутой системе сосудов под действием силы ритмически сокращающегося сердца и не {enter}
SendPlay, {T}
sleep 2000
SendPlay, сообщается непосредственно с другими тканями тела ввиду наличия гистогематических барьеров. {enter}
SendPlay, {T}
sleep 2000
SendPlay, У позвоночных кровь имеет красный цвет (от бледно- до тёмно-красного) из-за наличия в {enter}
SendPlay, {T}
sleep 2000
SendPlay,  эритроцитах гемоглобина, переносящего кислород. У человека насыщенная кислородом кровь {enter}
SendPlay, {T}
sleep 2000
SendPlay, (артериальная) ярко-красная, лишённая его (венозная) более тёмная. У некоторых моллюсков и {enter}
SendPlay, {T}
sleep 2000
SendPlay, членистоногих кровь (точнее, гемолимфа) голубая за счёт гемоцианина.{enter}
SendPlay, {T}
sleep 2000
SendPlay,  В среднем у мужчин в норме объём крови составляет 5,2 л, у женщин — 3,9 л, а у новорожденных —{enter}
SendPlay, {T}
sleep 2000
SendPlay, 200—350 мл. Массовая доля крови в теле взрослого человека составляет 6—8 процентов.{enter}
SendPlay, {T}
sleep 2000
SendPlay, Лекция завершена.{enter}
sleep 111
sendplay {f12}
}
return

:*?:лекгол::
{
Sendmessage, 0x50,, 0x4190419,, A
sleep 250
SendPlay, Сейчас будет проведена лекция "Головная боль".{enter}
SendPlay, {T}
sleep 2000
SendPlay,  Головная боль — один из наиболее распространённых неспецифических симптомов разнообразных  {enter}
SendPlay, {T}
sleep 2000
SendPlay, заболеваний и патологических состояний, представляющий собой боль в области головы.  {enter}
SendPlay, {T}
sleep 2000
SendPlay, Наиболее часто встречаются первичные головные боли ( 95–98 процентов всех форм цефалгий):головная {enter}
SendPlay, {T}
sleep 2000
SendPlay, боль напряжения и мигрень. Диагноз первичной формы головной боли предполагает, что анамнез, {enter}
SendPlay, {T}
sleep 2000
SendPlay, физикальный и неврологический осмотр, а также дополнительные методы исследования не {enter}
SendPlay, {T}
sleep 2000
SendPlay, выявляют органической причины, т.е. исключают вторичный характер головной боли. Термин {enter}
SendPlay, {T}
sleep 2000
SendPlay,  «вторичная» головная боль используется для обозначения состояний, которые связаны или {enter}
SendPlay, {T}
sleep 2000
SendPlay, являются следствием каких-либо заболеваний. Существует огромное количество различных форм {enter}
SendPlay, {T}
sleep 2000
SendPlay, головных болей, причины которых разнообразны — от самых безобидных до представляющих{enter}
SendPlay, {T}
sleep 2000
SendPlay,  опасность для жизни. Головная боль не является болевым ощущением нервной ткани мозга,{enter}
SendPlay, {T}
sleep 2000
SendPlay,  поскольку в ней отсутствуют болевые рецепторы.{enter}
SendPlay, {T}
sleep 2000
SendPlay, Лекция завершена.{enter}
sleep 111
sendplay {f12}
}
return

:*?:лекгли::
{
Sendmessage, 0x50,, 0x4190419,, A
sleep 250
SendPlay, Сейчас будет проведена лекция "Причины появляния глистов".{enter}
SendPlay, {T}
sleep 2000
SendPlay,  Главная причина заболеваемости гельминтами заключается в широкой  {enter}
SendPlay, {T}
sleep 2000
SendPlay, распространенности личинок и яиц паразитов в окружающей ребенка среде и несоблюдении  {enter}
SendPlay, {T}
sleep 2000
SendPlay, правил личной гигиены. Способ распространения паразитической инфекции — {enter}
SendPlay, {T}
sleep 2000
SendPlay, фекально-оральный. Яйца гельминтов выделяются с калом зараженных людей и животных. {enter}
SendPlay, {T}
sleep 2000
SendPlay, У человека после туалета яйца глистов могут остаться на коже рук, под ногтями или на белье. {enter}
SendPlay, {T}
sleep 2000
SendPlay, Чаще всего дети заражаются в местах скопления большого количества людей (в детских садах,н {enter}
SendPlay, {T}
sleep 2000
SendPlay,  школах, на детских площадках). Заражение происходит через совместное использование {enter}
SendPlay, {T}
sleep 2000
SendPlay, игрушек, спортивного инвентаря и т.д. Помимо этого выделяются следующие причины развития {enter}
SendPlay, {T}
sleep 2000
SendPlay, глистной инвазии: употребление некачественной воды и пищи, зараженной яйцами гельминтов; {enter}
SendPlay, {T}
sleep 2000
SendPlay,  использование чужих предметов личного пользования (полотенец, белья); плохая обработка {enter}
SendPlay, {T}
sleep 2000
SendPlay,  овощей и фруктов; близкие контакты ребенка с домашними и уличными животными.{enter}
SendPlay, {T}
sleep 2000
SendPlay, Лекция завершена.{enter}
sleep 111
sendplay {f12}
}
return

:*?:леквес::
{
Sendmessage, 0x50,, 0x4190419,, A
sleep 250
SendPlay, Сейчас будет проведена лекция "Появление веснушек".{enter}
SendPlay, {T}
sleep 2000
SendPlay,  Веснушки — это маленькие желтые пигментные пятна на коже, которые появляются {enter}
SendPlay, {T}
sleep 2000
SendPlay, преимущественно на лице, кистях рук, но иногда и на туловище. Причиной появления веснушек {enter}
SendPlay, {T}
sleep 2000
SendPlay, является наличие красителя под названием меланин в коже человека. Они возникают {enter}
SendPlay, {T}
sleep 2000
SendPlay, преимущественно у рыжеволосых и светловолосых и намного реже у брюнетов. Цвет веснушек {enter}
SendPlay, {T}
sleep 2000
SendPlay,  (цвет меланина в них) может варьироваться от светлого загара до тёмно-бурого, в зависимости {enter}
SendPlay, {T}
sleep 2000
SendPlay, от воздействия Солнца и тепла. Кроме того солнечные лучи могут спровоцировать появлени {enter}
SendPlay, {T}
sleep 2000
SendPlay,  новых конопушек. Веснушки нередко представляют собой наследственное явление, однако гены, {enter}
SendPlay, {T}
sleep 2000
SendPlay, ответственные за развитие веснушек, не идентифицированы. {enter}
SendPlay, {T}
sleep 2000
SendPlay, Лекция завершена.{enter}
sleep 111
sendplay {f12}
}
return

:*?:леккур::
{
Sendmessage, 0x50,, 0x4190419,, A
sleep 250
SendPlay, Сейчас будет проведена лекция: "Курение".{enter}
SendPlay, {T}
sleep 2000
SendPlay, О вреде курения и алкоголя известно немало фактов. {enter}
SendPlay, {T}
sleep 2000
SendPlay, Однако беспокойство учёных, вызванное распространением этих привычек растёт. {enter}
SendPlay, {T}
sleep 2000
SendPlay,  Сегодня отмечено увеличение доли подростков, начавших купить и выпивать до 13-летного возраста. {enter}
SendPlay, {T}
sleep 2000
SendPlay, Самым критическим пиком приобщения к курению является подростковый возраст 14-17 лет. {enter}
SendPlay, {T}
sleep 2000
SendPlay, Что же такое курение? Курение – это не безобидное занятие, которое можно бросить без усилий. {enter}
SendPlay, {T}
sleep 2000
SendPlay, Это скрытая наркомания, и тем опасная, что многие её не принимают всерьёз. {enter}
SendPlay, {T}
sleep 2000
SendPlay, Зло приносимое курением так выросло, что вмире приобрела значение социальной проблемы. {enter}
SendPlay, {T}
sleep 2000
SendPlay, Сигареты готовятся из высушенных листьев табака, во время курения происходит их сухая перегонка {enter}
SendPlay, {T}
sleep 2000
SendPlay,  ...сопровождаемая большим количеством вредных веществ: никотина, угарного газа, аммиака и др.{enter}
SendPlay, {T}
sleep 2000
SendPlay, Но ввиду того, что никотин попадает в организм не сразу, а частями, он успевает обезвредиться.{enter}
SendPlay, {T}
sleep 2000
SendPlay, Самую большую опасность никотин представляет для нервной системы.{enter}
SendPlay, {T}
sleep 2000
SendPlay, При чрезмерном увлечении этой привычкой наблюдается отчётливая желтизна кожи и ногтей.{enter}
SendPlay, {T}
sleep 2000
SendPlay, Лекция завершена.{enter}
sleep 111
sendplay {f12}
}
return

:*?:лексах::
{
Sendmessage, 0x50,, 0x4190419,, A
sleep 250
SendPlay, Сейчас будет проведена лекция "Сахарный диабет".{enter}
SendPlay, {T}
sleep 2000
SendPlay, Сахарный диабет — группа эндокринных заболеваний, связанных с нарушением усвоения глюкозы {enter}
SendPlay, {T}
sleep 2000
SendPlay, и развивающихся вследствие абсолютной или относительной (нарушение взаимодействия с {enter}
SendPlay, {T}
sleep 2000
SendPlay,  клетками-мишенями) недостаточности гормона инсулина, в результате чего развивается {enter}
SendPlay, {T}
sleep 2000
SendPlay, гипергликемия — стойкое увеличение содержания глюкозы в крови. Заболевание характеризуется {enter}
SendPlay, {T}
sleep 2000
SendPlay, хроническим течением, а также нарушением всех видов обмена веществ: углеводного, жирового, {enter}
SendPlay, {T}
sleep 2000
SendPlay, белкового, минерального и водно-солевого. Кроме человека данному заболеванию подвержены {enter}
SendPlay, {T}
sleep 2000
SendPlay, также некоторые животные, например кошки и собаки. {enter}
SendPlay, {T}
sleep 2000
SendPlay, Лекция завершена.{enter}
sleep 111
sendplay {f12}
}
return

:*?:лекдиар::
{
Sendmessage, 0x50,, 0x4190419,, A
sleep 250
SendPlay, Сейчас будет проведена лекция "Диарея".{enter}
SendPlay, {T}
sleep 2000
SendPlay,  Диарея, народное название — понос — патологическое состояние, при котором у больного {enter}
SendPlay, {T}
sleep 2000
SendPlay, наблюдается учащённая (более 2 раз в сутки) дефекация, при этом стул становится водянистым,{enter}
SendPlay, {T}
sleep 2000
SendPlay,  имеет объём более 200 мл и часто сопровождается болевыми ощущениями в области живота {enter}
SendPlay, {T}
sleep 2000
SendPlay, экстренными позывами и анальным недержанием. В странах третьего мира диарея является {enter}
SendPlay, {T}
sleep 2000
SendPlay, частой причиной младенческой смертности: в 2009 году более 1,5 миллиона детей (возраста до {enter}
SendPlay, {T}
sleep 2000
SendPlay, 5 лет) умерли в результате данного патологического состояния. Диарея входит в десятку {enter}
SendPlay, {T}
sleep 2000
SendPlay, ведущих причин смертности. Различают острую и хроническую диарею. Острая диарея длится {enter}
SendPlay, {T}
sleep 2000
SendPlay, до двух недель, после чего её можно классифицировать как продолжительную, а затем и{enter}
SendPlay, {T}
sleep 2000
SendPlay, хроническую. От острой диареи различного генеза страдают порядка 1,7 миллиарда человек в год.{enter}
SendPlay, {T}
sleep 2000
SendPlay, Хроническая диарея, по разным оценкам, встречается у 7—14 процентов взрослого населения Земли.{enter}
SendPlay, {T}
sleep 2000
SendPlay, Лекция завершена.{enter}
sleep 111
sendplay {f12}
}
return

:*?:леккар::
{
Sendmessage, 0x50,, 0x4190419,, A
sleep 250
SendPlay, Сейчас будет проведена лекция "Кариес зубов".{enter}
SendPlay, {T}
sleep 2000
SendPlay,  Кариес зубов — сложный, медленно текущий патологический процесс, протекающий в твёрдых {enter}
SendPlay, {T}
sleep 2000
SendPlay, тканях зуба и развивающийся в результате комплексного воздействия неблагоприятных внешних{enter}
SendPlay, {T}
sleep 2000
SendPlay,  и внутренних факторов. В начальной стадии развития кариес характеризуется очаговой {enter}
SendPlay, {T}
sleep 2000
SendPlay, деминерализацией неорганической части эмали и разрушением её органического матрикса. {enter}
SendPlay, {T}
sleep 2000
SendPlay, В конечном итоге это приводит к разрушению твёрдых тканей зуба с образованием полости в {enter}
SendPlay, {T}
sleep 2000
SendPlay, дентине, а при отсутствии лечения — к возникновению воспалительных осложнений со стороны {enter}
SendPlay, {T}
sleep 2000
SendPlay, пульпы и периодонта. {enter}
SendPlay, {T}
sleep 2000
SendPlay, Лекция завершена.{enter}
sleep 111
sendplay {f12}
}
return

:*?:лекбег::
{
Sendmessage, 0x50,, 0x4190419,, A
sleep 250
SendPlay, Сейчас будет проведена лекция "Бег".{enter}
SendPlay, {T}
sleep 2000
SendPlay,  Бег — один из способов передвижения (локомоции) человека и животных; отличается наличием {enter}
SendPlay, {T}
sleep 2000
SendPlay, так называемой «фазы полёта» и осуществляется в результате сложной координированной{enter}
SendPlay, {T}
sleep 2000
SendPlay,  деятельности скелетных мышц и конечностей. Для бега характерен, в целом, тот же цикл {enter}
SendPlay, {T}
sleep 2000
SendPlay, движений, что и при ходьбе, те же действующие силы и функциональные группы мышц. {enter}
SendPlay, {T}
sleep 2000
SendPlay, Отличием бега от ходьбы является отсутствие при беге фазы двойной опоры. Бег предоставляет {enter}
SendPlay, {T}
sleep 2000
SendPlay, хорошие условия в качестве аэробной тренировки, которая увеличивает порог выносливости, {enter}
SendPlay, {T}
sleep 2000
SendPlay, положительно влияет на сердечно-сосудистую систему, повышает обмен веществ в организме и, {enter}
SendPlay, {T}
sleep 2000
SendPlay, таким образом, помогает осуществлять контроль за весом тела. Бег позитивно влияет на{enter}
SendPlay, {T}
sleep 2000
SendPlay, имунную систему и улучшает тонус кожи. Укрепление мускулатуры ног и улучшение обмена{enter}
SendPlay, {T}
sleep 2000
SendPlay, веществ помогает предотвратить и устранить целлюлит. Бег позволяет наладить ритмическую{enter}
SendPlay, {T}
sleep 2000
SendPlay,  работу эндокринной и нервной систем. Во время бега, когда человек постоянно преодолевает{enter}
SendPlay, {T}
sleep 2000
SendPlay, земную гравитацию, подскакивая и опускаясь в вертикальном положении, кровоток в сосудах{enter}
SendPlay, {T}
sleep 2000
SendPlay, входит в резонанс с бегом, при этом активизируются ранее незадействованные капилляры.{enter}
SendPlay, {T}
sleep 2000
SendPlay, Микроциркуляция крови активизирует деятельность органов внутренней секреции. Поток{enter}
SendPlay, {T}
sleep 2000
SendPlay,  гормонов возрастает и способствует координированию деятельности других органов и систем{enter}
SendPlay, {T}
sleep 2000
SendPlay,  организма.{enter}
SendPlay, {T}
sleep 2000
SendPlay, Лекция завершена.{enter}
sleep 111
sendplay {f12}
}
return

:*?:лекинф::
{
Sendmessage, 0x50,, 0x4190419,, A
sleep 250
SendPlay,  Сейчас будет проведена лекция "Первые действия при инфаркте".{enter}
SendPlay, {T}
sleep 2000
SendPlay, Инфаркт миокарда – омертвение участка сердечной мышцы, возникающее вследствие {enter}
SendPlay, {T}
sleep 2000
SendPlay, нарушения кровоснабжения сердца в результате атеросклероза сосудов, их спазма или закупорки{enter}
SendPlay, {T}
sleep 2000
SendPlay, сгустками крови. Тяжелыми проявлениями инфаркта миокарда являются острая {enter}
SendPlay, {T}
sleep 2000
SendPlay, сердечно-сосудистая недостаточность, отек легких и фибрилляция желудочков (хаотичное {enter}
SendPlay, {T}
sleep 2000
SendPlay, сокращение мышечных волокон). Типичные признаки инфаркта: давящая, сжимающая боль за {enter}
SendPlay, {T}
sleep 2000
SendPlay, грудиной, которая может отдавать в спину, плечи, лопатки, руку, шею, нижнюю челюсть;  {enter}
SendPlay, {T}
sleep 2000
SendPlay, боль продолжается более 15 минут и не проходит после приема нитроглицерина; {enter}
SendPlay, {T}
sleep 2000
SendPlay, лицо бледнеет, покрывается потом; say нарастает слабость, учащаются пульс и дыхание,{enter}
SendPlay, {T}
sleep 2000
SendPlay, появляется чувство страха. Первая помощь при инфаркте до приезда скорой помощи:{enter}
SendPlay, {T}
sleep 2000
SendPlay,  принять положение "сидя", расстегнуть воротник, открыть окна; положить под язык таблетку{enter}
SendPlay, {T}
sleep 2000
SendPlay, нитроглицерина (повторять прием можно каждые 5 минут, но не более 3-х раз);{enter}
SendPlay, {T}
sleep 2000
SendPlay, можно принять размельченную таблетку аспирина; {enter}
SendPlay, {T}
sleep 2000
sendplay say измерьте артериальное давление, если {enter}
sendplay {T}
sleep 2000
SendPlay, оно повышено примите меры к его снижению.{enter}
SendPlay, {T}
sleep 2000
SendPlay, Лекция завершена.{enter}
sleep 111
sendplay {f12}
}
return

:*?:лекинс::
{
Sendmessage, 0x50,, 0x4190419,, A
sleep 250
SendPlay, Сейчас будет проведена лекция "Первые действия при инсульте".{enter}
SendPlay, {T}
sleep 2000
SendPlay, Инсульт (инфаркт головного мозга) — одна из основных причин инвалидизации и смертности {enter}
SendPlay, {T}
sleep 2000
SendPlay, взрослого населения нашей планеты. В цивилизованных странах ежегодно регистрируются{enter}
SendPlay, {T}
sleep 2000
SendPlay, сотни тысяч случаев инсульта. К сожалению, если «пропустить» первые минуты и часы этого {enter}
SendPlay, {T}
sleep 2000
SendPlay, грозного заболевания, процесс становится необратимым. До приезда специалистов следует {enter}
SendPlay, {T}
sleep 2000
SendPlay, уложить больного на высокие подушки; открыть форточку, снять тесную одежду, расстегнуть {enter}
SendPlay, {T}
sleep 2000
SendPlay, воротничок рубашки, тугой ремень или пояс; измерить артериальное давление; дать больному  {enter}
SendPlay, {T}
sleep 2000
SendPlay, Лекция завершена.{enter}
sleep 111
sendplay {f12}
}
return

:*?:лекзап::
{
Sendmessage, 0x50,, 0x4190419,, A
sleep 250
SendPlay, Сейчас будет проведена лекция "Запор".{enter}
SendPlay, {T}
sleep 2000
SendPlay, Запор — замедленная, затруднённая или систематически недостаточная дефекация (опорожнение {enter}
SendPlay, {T}
sleep 2000
SendPlay, кишечника, калоизвержение). Причины возникновения запоров могут быть самые разнообразные,{enter}
SendPlay, {T}
sleep 2000
SendPlay, в частности, неправильное питание, в том числе недостаток в рационе пищевых волокон или {enter}
SendPlay, {T}
sleep 2000
SendPlay, потребление слабительных, беременность, путешествия, приём некоторых медикаментов, {enter}
SendPlay, {T}
sleep 2000
SendPlay, болезни анальной области (геморрой, трещина заднего прохода), моторные нарушения кишечника, {enter}
SendPlay, {T}
sleep 2000
SendPlay, патологии тазового дна, аномалии развития толстой кишки и её иннервации, травмы спинного  {enter}
SendPlay, {T}
sleep 2000
SendPlay, мозга, синдром раздражённого кишечника, гормональные нарушения и другое.{enter}
SendPlay, {T}
sleep 2000
SendPlay, Лекция завершена.{enter}
sleep 111
sendplay {f12}
}
return

:*?:лекперп::
{
Sendmessage, 0x50,, 0x4190419,, A
sleep 250
SendPlay, Сейчас будет проведена лекция "Перелом пальцев кисти".{enter}
SendPlay, {T}
sleep 2000
SendPlay, Перелом пальцев кисти — состояние, при котором кости кистевых пальцев выходят из (опорожнение {enter}
SendPlay, {T}
sleep 2000
SendPlay, правильного положения. Как правило, возникает при ударах и падениях. Переломы пальцев{enter}
SendPlay, {T}
sleep 2000
SendPlay, происходят довольно часто, случаются они под влиянием прямого удара или же непрямой травмы. {enter}
SendPlay, {T}
sleep 2000
SendPlay, Пострадавший обычно жалуется на сильные боли в сломанном пальце, на отек пальца и {enter}
SendPlay, {T}
sleep 2000
SendPlay, припухлость. Движения в пальце бывают ограничены, а также резко болезненны, в особенности {enter}
SendPlay, {T}
sleep 2000
SendPlay, при попытке разгибания пальца. Во время осмотра можно заметить деформацию и искривление  {enter}
SendPlay, {T}
sleep 2000
SendPlay, пальца. Диагноз уточняется с помощью рентгенологического исследования.{enter}
SendPlay, {T}
sleep 2000
SendPlay, Лекция завершена.{enter}
sleep 111
sendplay {f12}
}
return

:*?:лекрод::
{
Sendmessage, 0x50,, 0x4190419,, A
sleep 250
SendPlay, Сейчас будет проведена лекция "Появление родинок".{enter}
SendPlay, {T}
sleep 2000
SendPlay, Новая родинка появляется, когда меланоциты, клетки, продуцирующие пигмент в коже человека, {enter}
SendPlay, {T}
sleep 2000
SendPlay, размножаются или делятся, образуя характерные родинки, которые на поверхности кожи.{enter}
SendPlay, {T}
sleep 2000
SendPlay, Меланоциты содержат пигмент, обеспечивающий типичный цвет родинки. {enter}
SendPlay, {T}
sleep 2000
SendPlay, Родинки могут быть доброкачественными или злокачественными. Злокачественные родинки,{enter}
SendPlay, {T}
sleep 2000
SendPlay, например, меланомы, появляются в результате генетических мутаций. Точная причина {enter}
SendPlay, {T}
sleep 2000
SendPlay, образования доброкачественных родинок остается неизвестной.  {enter}
SendPlay, {T}
sleep 2000
SendPlay, Лекция завершена.{enter}
sleep 111
sendplay {f12}
}
return

:*?:лекног:
{
Sendmessage, 0x50,, 0x4190419,, A
sleep 250
SendPlay, Сейчас будет проведена лекция "Ногти".{enter}
SendPlay, {T}
sleep 2000
SendPlay, Как ни странно, но функция ногтя — защита концевых фаланг пальцев, чтобы не повредить {enter}
SendPlay, {T}
sleep 2000
SendPlay, мягкие ткани, в которых находятся нервные окончания. Ногти являются жестким укрытием{enter}
SendPlay, {T}
sleep 2000
SendPlay, для защиты нежных кончиков пальцев, с помощью которых мы захватываем различные предметы {enter}
SendPlay, {T}
sleep 2000
SendPlay,  и физически ощущаем окружающие нас тела. Ногти позволяют нам подцеплять что-либо,{enter}
SendPlay, {T}
sleep 2000
SendPlay, если предмет невелик, то без таких твердых образований его вообще ухватить трудно. {enter}
SendPlay, {T}
sleep 2000
SendPlay, Интересный факт: известно, что общая длина подстриженных за всю жизнь ногтей у мужчин  {enter}
SendPlay, {T}
sleep 2000
SendPlay, достигает 3,9 м, а у женщин - 4,3 м.{enter}
SendPlay, {T}
sleep 2000
SendPlay, Лекция завершена.{enter}
sleep 111
sendplay {f12}
}
return

:*?:леклег::
{
Sendmessage, 0x50,, 0x4190419,, A
sleep 250
SendPlay, Сейчас будет проведена лекция "Лёгкие".{enter}
SendPlay, {T}
sleep 2000
SendPlay, Лёгкие — органы воздушного дыхания у человека, всех млекопитающих, птиц, {enter}
SendPlay, {T}
sleep 2000
SendPlay, пресмыкающихся, большинства земноводных, а также у некоторых рыб (двоякодышащих,{enter}
SendPlay, {T}
sleep 2000
SendPlay, кистепёрых и многопёровых). Лёгкими называют также органы дыхания у некоторых {enter}
SendPlay, {T}
sleep 2000
SendPlay,  беспозвоночных животных (у некоторых моллюсков, голотурий, паукообразных). В лёгких{enter}
SendPlay, {T}
sleep 2000
SendPlay, осуществляется газообмен между воздухом, находящимся в паренхиме лёгких, и кровью, {enter}
SendPlay, {T}
sleep 2000
SendPlay, протекающей по лёгочным капиллярам. При вдохе давление в лёгких ниже атмосферного, а при  {enter}
SendPlay, {T}
sleep 2000
SendPlay, выдохе — выше, что даёт возможность воздуху двигаться в лёгкие из атмосферы и назад. При{enter}
SendPlay, {T}
sleep 2000
SendPlay, вдохе диафрагма опускается, рёбра поднимаются, расстояние между ними увеличивается.{enter}
SendPlay, {T}
sleep 2000
SendPlay, Обычный спокойный выдох происходит в большой степени пассивно, при этом активно работают{enter}
SendPlay, {T}
sleep 2000
SendPlay, внутренние межрёберные мышцы и некоторые мышцы живота. Интенсивный выдох происходит {enter}
SendPlay, {T}
sleep 2000
SendPlay, активно, с участием прямых мышц живота, подвздошно-рёберных мышц и других. При выдохе{enter}
SendPlay, {T}
sleep 2000
SendPlay, диафрагма поднимается, рёбра перемещаются вниз, расстояние между ними уменьшается.{enter}
SendPlay, {T}
sleep 2000
SendPlay, Лекция завершена.{enter}
sleep 111
sendplay {f12}
}
return

:*?:леквита::
{
Sendmessage, 0x50,, 0x4190419,, A
sleep 250
SendPlay, Сейчас будет проведена лекция "Витамины".{enter}
SendPlay, {T}
sleep 2000
SendPlay, Витамины — это особые вещества, которые играют огромную роль в жизнедеятельности {enter}
SendPlay, {T}
sleep 2000
SendPlay, организма, участвуют в обмене веществ, являются биологическими ускорителями химических{enter}
SendPlay, {T}
sleep 2000
SendPlay, реакций, протекающих в клетке, повышают устойчивость к инфекционным заболеваниям, {enter}
SendPlay, {T}
sleep 2000
SendPlay,  повышают работоспособность, облегчают течение многих болезней, снижают отрицательное{enter}
SendPlay, {T}
sleep 2000
SendPlay, влияние различных профессиональных вредностей и т. п. Если витаминов поступает мало, говорят {enter}
SendPlay, {T}
sleep 2000
SendPlay,  о гиповитаминозе, если же их излишек — это гипервитаминоз. Витамины бывают разные. О том,  {enter}
SendPlay, {T}
sleep 2000
SendPlay, что есть витамины А, B, C, D, E, K, знают многие, а вот о том, что их можно разделить на витамины {enter}
SendPlay, {T}
sleep 2000
SendPlay, для ногтей, кожи, волос, сердца, глаз, знают не все. В особую группу относят витамины для{enter}
SendPlay, {T}
sleep 2000
SendPlay, мужчин, женщин, детей, беременных и другие.{enter}
SendPlay, {T}
sleep 2000
SendPlay, Лекция завершена.{enter}
sleep 111
sendplay {f12}
}
return

:*?:лекалек::
{
Sendmessage, 0x50,, 0x4190419,, A
sleep 250
SendPlay, Сейчас будет проведена лекция "Алексия".{enter}
SendPlay, {T}
sleep 2000
SendPlay, Алексия — это нарушения чтения, возникающие при поражении различных отделов коры {enter}
SendPlay, {T}
sleep 2000
SendPlay, левого полушария (у правшей), или неспособность овладения процессом чтения.{enter}
SendPlay, {T}
sleep 2000
SendPlay, Нередко алексия сочетается с потерей способности писать (аграфией) и нарушением речи (афазия). {enter}
SendPlay, {T}
sleep 2000
SendPlay,   В зависимости от области поражения коры больших полушарий различают несколько форм алексии: {enter}
SendPlay, {T}
sleep 2000
SendPlay, чистая алексия и алексия с аграфией. Чистая алексия развивается при повреждении {enter}
SendPlay, {T}
sleep 2000
SendPlay,  медиальной поверхности затылочной доли, которое прерывает связи зрительной коры с  {enter}
SendPlay, {T}
sleep 2000
SendPlay, левой височно-теменной областью. Алексия с аграфией характерна для повреждения {enter}
SendPlay, {T}
sleep 2000
SendPlay, конвекситальной поверхности затылочной доли, ближе к височной доле, и проявляется не только{enter}
SendPlay, {T}
sleep 2000
SendPlay, нарушением чтения, но и дефектами письма.{enter}
SendPlay, {T}
sleep 2000
SendPlay, Лекция завершена.{enter}
sleep 111
sendplay {f12}
}
return

:*?:лекдиаб::
{
Sendmessage, 0x50,, 0x4190419,, A
sleep 250
SendPlay, Сейчас будет проведена лекция "Диабет".{enter}
SendPlay, {T}
sleep 2000
SendPlay, Диабет — это хроническая болезнь, развивающаяся в тех случаях, когда поджелудочная железа не {enter}
SendPlay, {T}
sleep 2000
SendPlay, вырабатывает достаточно инсулина или когда организм не может эффективно использовать {enter}
SendPlay, {T}
sleep 2000
SendPlay, вырабатываемый им инсулин. Инсулин — это гормон, регулирующий уровень содержания сахара {enter}
SendPlay, {T}
sleep 2000
SendPlay, в крови. Общим результатом неконтролируемого диабета является гипергликемия, или повышенный {enter}
SendPlay, {T}
sleep 2000
SendPlay, уровень содержания сахара в крови, что со временем приводит к серьезному повреждению многих {enter}
SendPlay, {T}
sleep 2000
SendPlay,  систем организма, особенно нервов и кровеносных сосудов. Показано, что простые меры по  {enter}
SendPlay, {T}
sleep 2000
SendPlay, поддержанию здорового образа жизни способствуют профилактике диабета 2-го типа либо {enter}
SendPlay, {T}
sleep 2000
SendPlay, позволяют отсрочить его возникновение. Стремясь предупредить возникновение диабета 2-го типа {enter}
SendPlay, {T}
sleep 2000
SendPlay, и связанных с ним осложнений, необходимо: добиться здоровой массы тела и поддерживать ее; {enter}
SendPlay, {T}
sleep 2000
SendPlay, поддерживать физическую активность — по меньшей мере, 30 минут регулярной активности{enter}
SendPlay, {T}
sleep 2000
SendPlay, умеренной интенсивности в течение большинства дней; для контроля веса необходима{enter}
SendPlay, {T}
sleep 2000
SendPlay,  дополнительная активность; придерживаться здорового питания и уменьшать потребление сахара {enter}
SendPlay, {T}
sleep 2000
SendPlay,  и насыщенных жиров; воздерживаться от употребления табака — курение повышает риск развития{enter}
SendPlay, {T}
sleep 2000
SendPlay, сердечно-сосудистых заболеваний.{enter}
SendPlay, {T}
sleep 2000
SendPlay, Лекция завершена.{enter}
sleep 111
sendplay {f12}
}
return

:*?:леккат::
{
Sendmessage, 0x50,, 0x4190419,, A
sleep 250
SendPlay, Сейчас будет проведена лекция "Катаракта".{enter}
SendPlay, {T}
sleep 2000
SendPlay, Катарактой называют потерю прозрачности и появление помутнений в естественной линзе {enter}
SendPlay, {T}
sleep 2000
SendPlay, глаза — хрусталике. Хрусталик расположен позади радужки, внутри глаза. Он выполняет роль{enter}
SendPlay, {T}
sleep 2000
SendPlay, прозрачной линзы, благодаря которой изображение фокусируется на сетчатке. Катаракта {enter}
SendPlay, {T}
sleep 2000
SendPlay,   развивается на одном или обоих глазах. Симптомы катаракты: {enter}
SendPlay, {T}
sleep 2000
SendPlay, Снижение остроты зрения, снижение ясности зрения, некорректируемое очками или линзами, {enter}
SendPlay, {T}
sleep 2000
SendPlay,  Снижение яркости цветовосприятия. Цвета кажутся блеклыми и тусклыми, появляются блики или  {enter}
SendPlay, {T}
sleep 2000
SendPlay, ореолы вокруг источников света. Катаракта может быть диагностирована на обычном приеме у {enter}
SendPlay, {T}
sleep 2000
SendPlay,  врача-офтальмолога. Расширенный спектр обследований назначают перед оперативным {enter}
SendPlay, {T}
sleep 2000
SendPlay, лечением катаракты. На сегодняшний день не существует способов предотвратить развитие {enter}
SendPlay, {T}
sleep 2000
SendPlay, данной болезни, однако замедлить ее развитие совершенно реально. Вылечиться от катаракт {enter}
SendPlay, {T}
sleep 2000
SendPlay, возможно только при помощи микрохирургической операции – факоэмульсификации катаракты.{enter}
SendPlay, {T}
sleep 2000
SendPlay, На сегодняшний день существуют современные искусственные хрусталики, которые помогут {enter}
SendPlay, {T}
sleep 2000
SendPlay, полностью вернуть Вам зрение и избавиться от очков после операции. {enter}
SendPlay, {T}
sleep 2000
SendPlay, Лекция завершена.{enter}
sleep 111
sendplay {f12}
}
return

:*?:лекпмпотр::
{
Sendmessage, 0x50,, 0x4190419,, A
sleep 250
SendPlay, Сейчас будет проведена лекция "Первая помощь при отравлении".{enter}
SendPlay, {T}
sleep 2000
SendPlay,  Отравление возникает из-за несвежести каких-либо продуктов, поступающих в организм. {enter}
SendPlay, {T}
sleep 2000
SendPlay, При отравлении нужно:{enter}
SendPlay, {T}
sleep 2000
SendPlay, Промыть желудок содовым раствором и вызвать рвоту; {enter}
SendPlay, {T}
sleep 2000
SendPlay,  Дать пострадавшему обволакивающие средства типа Алмагеля, белка, крахмала; {enter}
SendPlay, {T}
sleep 2000
SendPlay, Дать абсорбенты – активированный уголь, Энтеросгель, Лактофильтрум; {enter}
SendPlay, {T}
sleep 2000
SendPlay,  Как можно быстрее доставить пострадавшего в больницу.  {enter}
SendPlay, {T}
sleep 2000
SendPlay, Лекция завершена.{enter}
sleep 111
sendplay {f12}
}
return

:*?:лекпмпкр::
{
Sendmessage, 0x50,, 0x4190419,, A
sleep 250
SendPlay, Сейчас будет проведена лекция "Первая помощь при кровотечениях".{enter}
SendPlay, {T}
sleep 2000
SendPlay,  Кровотечение — это истечение крови из кровеносных сосудов в органы, ткани, естественные {enter}
SendPlay, {T}
sleep 2000
SendPlay, полости организма или наружу. При развитии сильного кровотечения из крупных сосудов{enter}
SendPlay, {T}
sleep 2000
SendPlay, больному необходимо оказать медицинскую помощь, поскольку значительная потеря крови {enter}
SendPlay, {T}
sleep 2000
SendPlay,  представляет большую угрозу здоровью и может привести к летальному исходу. Причинами {enter}
SendPlay, {T}
sleep 2000
SendPlay, кровотечений всегда является повреждение стенки сосуда (артерий или вен). {enter}
SendPlay, {T}
sleep 2000
SendPlay,  При оказании первой помощи при артериальном кровотечении необходимо:  {enter}
SendPlay, {T}
sleep 2000
SendPlay, нажать большим пальцем руки на артерию выше раны, чтобы остановить или хотя бы ослабить {enter}
SendPlay, {T}
sleep 2000
SendPlay, кровотечение; наложить резиновый или любой другой самодельный жгут (что попадется под {enter}
SendPlay, {T}
sleep 2000
SendPlay, руки, например, ремень, шнур и тд) на артерию выше раны, это уменьшит потерю крови; оставить {enter}
SendPlay, {T}
sleep 2000
SendPlay, записку c указанием времени наложения жгута; перевязать рану; после оказания помощи {enter}
SendPlay, {T}
sleep 2000
SendPlay, пострадавшему, его следует немедленно отправить в специализированное медицинское {enter}
SendPlay, {T}
sleep 2000
SendPlay, учреждение (больницу или поликлинику).{enter}
SendPlay, {T}
sleep 2000
SendPlay, Лекция завершена.{enter}
sleep 111
sendplay {f12}
}
return

:*?:лекпмпож::
{
Sendmessage, 0x50,, 0x4190419,, A
sleep 250
SendPlay, Сейчас будет проведена лекция "Первая помощь при ожогах".{enter}
SendPlay, {T}
sleep 2000
SendPlay,  Ожог — повреждение тканей организма, вызванное действием высокой или низкой температуры, {enter}
SendPlay, {T}
sleep 2000
SendPlay, действием некоторых химических веществ (щелочей, кислот, солей тяжёлых металлов и других).{enter}
SendPlay, {T}
sleep 2000
SendPlay,  Различают 4 степени ожога: покраснение кожи, образование пузырей, омертвение всей толщ {enter}
SendPlay, {T}
sleep 2000
SendPlay,   кожи и обугливание тканей. Первая помощь: {enter}
SendPlay, {T}
sleep 2000
SendPlay, Удалить источники ожога. Если это горящая одежда, потушить огонь водой или пеной. Если ожог {enter}
SendPlay, {T}
sleep 2000
SendPlay,   получен вследствие контакта с химическими веществами, удалить остатки агрессивных веществ с  {enter}
SendPlay, {T}
sleep 2000
SendPlay, кожи. Важно помнить, что нельзя смывать водой негашеную известь, а также органические {enter}
SendPlay, {T}
sleep 2000
SendPlay, алюминиевые соединения, потому что они под воздействием воды воспламеняются. Такие {enter}
SendPlay, {T}
sleep 2000
SendPlay, вещества лучше сперва нейтрализовать или удалить сухой тканью. Охладить под проточной {enter}
SendPlay, {T}
sleep 2000
SendPlay, прохладной водой место ожога. Оптимальное время охлаждения – 15-20 мин. Если поражено {enter}
SendPlay, {T}
sleep 2000
SendPlay, более 20процентов участков тела, завернуть пострадавшего в чистую, смоченную в прохладной воде {enter}
SendPlay, {T}
sleep 2000
SendPlay, простынь. Защитить ожоговую рану от инфекции путем промывания раствором фурацилина.{enter}
SendPlay, {T}
sleep 2000
SendPlay, Нанести легкую стерильную марлевую повязку. При этом не сдавливать место ожога. Если{enter}
SendPlay, {T}
sleep 2000
SendPlay, обожжены конечности, стоит зафиксировать места ожогов, осторожно наложив шины. Дать{enter}
SendPlay, {T}
sleep 2000
SendPlay, пострадавшему любой анальгетик или жаропонижающее средство.{enter}
SendPlay, {T}
sleep 2000
SendPlay, Лекция завершена.{enter}
sleep 111
sendplay {f12}
}
return

:*?:лекпмппер::
{
Sendmessage, 0x50,, 0x4190419,, A
sleep 250
SendPlay, Сейчас будет проведена лекция "Первая помощь при переломах".{enter}
SendPlay, {T}
sleep 2000
SendPlay, Перелом — повреждение кости с нарушением ее целостности. Травматические переломы {enter}
SendPlay, {T}
sleep 2000
SendPlay, разделяют на открытые (есть повреждения кожи в зоне перелома) и закрытые (кожный покров не{enter}
SendPlay, {T}
sleep 2000
SendPlay,  нарушен). Оказание первой помощи при переломах конечностей во многом определяет исход {enter}
SendPlay, {T}
sleep 2000
SendPlay,   травмы: быстроту заживления, предупреждение ряда осложнений (кровотечение, смещение {enter}
SendPlay, {T}
sleep 2000
SendPlay, отломков, шок) и преследует три цели: {enter}
SendPlay, {T}
sleep 2000
SendPlay,  создание неподвижности костей в области перелома, профилактику шока и быструю доставку  {enter}
SendPlay, {T}
sleep 2000
SendPlay, пострадавшего в медицинское учреждение. Оказание первой помощи при закрытом переломе {enter}
SendPlay, {T}
sleep 2000
SendPlay, стоит начать с обеспечения неподвижности поврежденной конечности, например, положите ее {enter}
SendPlay, {T}
sleep 2000
SendPlay, на подушку и обеспечьте покой. На предполагаемую зону перелома положите что-нибудь {enter}
SendPlay, {T}
sleep 2000
SendPlay, холодное. Самому пострадавшему можно дать выпить горячий чай или обезболивающее средство. {enter}
SendPlay, {T}
sleep 2000
SendPlay, Если транспортировать пострадавшего вам придется самостоятельно, то предварительно {enter}
SendPlay, {T}
sleep 2000
SendPlay, Открытый перелом опаснее закрытого, так как есть возможность инфицирования отломков.{enter}
SendPlay, {T}
sleep 2000
SendPlay, Если есть кровотечение, его надо остановить. Если кровотечение незначительное, то достаточно {enter}
SendPlay, {T}
sleep 2000
SendPlay, наложить давящую повязку. При сильном кровотечении накладываем жгут, не забывая отметить {enter}
SendPlay, {T}
sleep 2000
SendPlay, время его наложения. Если время транспортировки занимает более 1,5-2 часов, то каждые 30 минут {enter}
SendPlay, {T}
sleep 2000
SendPlay, жгут необходимо ослаблять на 3-5 минут. Кожу вокруг раны необходимо обработать {enter}
SendPlay, {T}
sleep 2000
SendPlay, антисептическим средством (йод, зеленка). В случае его отсутствия рану надо закрыть {enter}
SendPlay, {T}
sleep 2000
SendPlay, хлопчатобумажной тканью. Теперь следует наложить шину, так же как и в случае закрытого{enter}
SendPlay, {T}
sleep 2000
SendPlay, перелома, но избегая места, где выступают наружу костные обломки и доставить пострадавшего в {enter}
SendPlay, {T}
sleep 2000
SendPlay, медицинское учреждение.{enter}
SendPlay, {T}
sleep 2000
SendPlay, Лекция завершена.{enter}
sleep 111
sendplay {f12}
}
return

:*?:лекпмпоб:
{
Sendmessage, 0x50,, 0x4190419,, A
sleep 250
SendPlay, Сейчас будет проведена лекция "Первая помощь при обмороке".{enter}
SendPlay, {T}
sleep 2000
SendPlay, Обморок — это недолговременная потеря сознания, вызванное кратковременным снижением {enter}
SendPlay, {T}
sleep 2000
SendPlay, обмена веществ в головном мозге,на фоне плохого его кровоснабжением. Больше трети людей в {enter}
SendPlay, {T}
sleep 2000
SendPlay,  различными внешними или внутренними факторами и не являются признаком серьёзных {enter}
SendPlay, {T}
sleep 2000
SendPlay,  заболеваний. Но вот если обмороки часто повторятся, то на это следует обратить особое внимание {enter}
SendPlay, {T}
sleep 2000
SendPlay,  и обратиться к квалифицированному специалисту (неврологу или кардиологу). Для оказания {enter}
SendPlay, {T}
sleep 2000
SendPlay, помощи при обмороке нужно устранить (при наличии) фактор возникновения обморока. Важно  {enter}
SendPlay, {T}
sleep 2000
SendPlay,  окно, чтобы дать приток свежего воздуха в помещение. Если потеря сознания произошла на улице, {enter}
SendPlay, {T}
sleep 2000
SendPlay, пациента нужно унести с дороги и обеспечить ему горизонтальное устойчивое положение. После {enter}
SendPlay, {T}
sleep 2000
SendPlay, требуется уложить пострадавшего и приподнять ему ноги, подложив под них какие-то подручные {enter}
SendPlay, {T}
sleep 2000
SendPlay, средства (сумку, одежду) для притока крови к голове. Ни в коем случае нельзя пытаться поставить {enter}
SendPlay, {T}
sleep 2000
SendPlay, человека, находящегося в обморочном состоянии, на ноги. Если возможность уложить человека {enter}
SendPlay, {T}
sleep 2000
SendPlay, отсутствует, нужно усадить его на стул, скамейку, пол и опустить его голову между коленями, это {enter}
SendPlay, {T}
sleep 2000
SendPlay, тоже вызовет прилив крови к голове. Важно обеспечить человеку приток свежего воздуха, {enter}
SendPlay, {T}
sleep 2000
SendPlay,  расстегнуть одежду, тугой воротник, галстук, бюстгальтер или пояс. Стоит прощупать пульс двумя {enter}
SendPlay, {T}
sleep 2000
SendPlay, пальцами на шее (в проекции сонной артерии) и послушать дыхание. Убедившись в их наличии, {enter}
SendPlay, {T}
sleep 2000
SendPlay, нужно попытаться привести пострадавшего в чувства: потереть ушные раковины, виски, пальцы {enter}
SendPlay, {T}
sleep 2000
SendPlay, рук, слегка похлопать по щекам, обрызгать лицо человека холодной водой, поднести к носу ватку {enter}
SendPlay, {T}
sleep 2000
SendPlay, или платок, смоченный нашатырным спиртом. Если дыхание и пульс отсутствуют, необходимо {enter}
SendPlay, {T}
sleep 2000
SendPlay, приступить к сердечно-легочной реанимации — требуется сделать непрямой массаж сердца {enter}
SendPlay, {T}
sleep 2000
SendPlay, и искусственное дыхание («рот в рот»).{enter}
SendPlay, {T}
sleep 2000
SendPlay, Лекция завершена.{enter}
sleep 111
sendplay {f12}
}
return

:*?:лекпмпог::
{
Sendmessage, 0x50,, 0x4190419,, A
sleep 300
SendPlay, Сейчас будет проведена лекция "Первая помощь при огнестрельном ранении".{enter}
SendPlay, {T}
sleep 2000
SendPlay, Огнестрельное ранение — это одно из наиболее травмирующих повреждений, которое можно {enter}
SendPlay, {T}
sleep 2000
SendPlay, получить. Трудно оценить тяжесть повреждений, вызванных огнестрельным ранением, и, как {enter}
SendPlay, {T}
sleep 2000
SendPlay,  правило, одной только первой помощи бывает недостаточно. По этой причине лучше всего как {enter}
SendPlay, {T}
sleep 2000
SendPlay,  можно скорее доставить пострадавшего в больницу. Оказание первой помощи: {enter}
SendPlay, {T}
sleep 2000
SendPlay,  Убедитесь, что вы находитесь в безопасности. Если произошел несчастный случай (например, на {enter}
SendPlay, {T}
sleep 2000
SendPlay, охоте), то убедитесь в том, что чье-либо огнестрельное оружие не направлено на людей, не  {enter}
SendPlay, {T}
sleep 2000
SendPlay,  заряжено и находится в безопасном и надежном месте. Если человек стал жертвой преступления, {enter}
SendPlay, {T}
sleep 2000
SendPlay, то убедитесь, что стрелявший больше не представляет угрозы, а вы с пострадавшим находитесь в {enter}
SendPlay, {T}
sleep 2000
SendPlay, безопасном для себя месте. При наличии средств индивидуальной защиты, наденьте их. {enter}
SendPlay, {T}
sleep 2000
SendPlay, Позвоните в службу неотложной помощи. Наберите 103 или другой номер для вызова экстренных {enter}
SendPlay, {T}
sleep 2000
SendPlay, служб. Если вы звоните с мобильного телефона, то не забудьте предоставить оператору {enter}
SendPlay, {T}
sleep 2000
SendPlay, информацию о своем местоположении. Иначе ваше местоположение будет трудно определить. {enter}
SendPlay, {T}
sleep 2000
SendPlay, Не двигайте пострадавшего. Не передвигайте пострадавшего, кроме случаев, когда нужно {enter}
SendPlay, {T}
sleep 2000
SendPlay,  обеспечить его безопасность или оказать медицинскую помощь. Передвинув пострадавшего, {enter}
SendPlay, {T}
sleep 2000
SendPlay, можно усугубить травму позвоночника. Приподняв место ранения, вы можете уменьшить {enter}
SendPlay, {T}
sleep 2000
SendPlay, кровотечение, но это следует делать, только если вы уверены, что нет повреждений позвоночника. {enter}
SendPlay, {T}
sleep 2000
SendPlay, Окажите прямое давление на рану. Возьмите в руку ткань, бинт или марлю и надавите. {enter}
SendPlay, {T}
sleep 2000
SendPlay, непосредственно на рану. Делайте так не менее десяти минут. Если кровотечение не прекращается, {enter}
SendPlay, {T}
sleep 2000
SendPlay, то проверьте расположение раны и, если нужно, подойдите к ней с другой стороны. Наложите {enter}
SendPlay, {T}
sleep 2000
SendPlay, новые повязки поверх старых; не снимайте повязки, когда они промокнут.{enter}
SendPlay, {T}
sleep 2000
SendPlay,  Перевяжите рану. Если кровотечение уменьшается, наложите на рану ткань или марлю. Оберните {enter}
SendPlay, {T}
sleep 2000
SendPlay, ее вокруг раны, чтобы оказать на нее давление. Однако не перетягивайте настолько туго, чтобы{enter}
SendPlay, {T}
sleep 2000
SendPlay, кровь перестала циркулировать или пострадавший перестал чувствовать свои конечности. {enter}
SendPlay, {T}
sleep 2000
SendPlay, Будьте готовы столкнуться с болевым шоком жертвы. Огнестрельные раны часто приводят к {enter}
SendPlay, {T}
sleep 2000
SendPlay, болевому шоку, состоянию, возникающему в результате травмы или потери крови. Ожидайте, что {enter}
SendPlay, {T}
sleep 2000
SendPlay, у пострадавшего с огнестрельным ранением появятся признаки шока и действуйте соответственно, {enter}
SendPlay, {T}
sleep 2000
SendPlay, прежде убедившись, что его температура не изменилась, и накройте пострадавшего, если он {enter}
SendPlay, {T}
sleep 2000
SendPlay, начнет мерзнуть. Ослабьте плотно прилегающую одежду и закутайте его в одеяло или пальто. {enter}
SendPlay, {T}
sleep 2000
SendPlay, Обычно у человека, испытывающего шок, немного приподнимают ноги. Но этого нельзя делать {enter}
SendPlay, {T}
sleep 2000
SendPlay, при травмах позвоночника или ранениях в туловище. {enter}
SendPlay, {T}
sleep 2000
SendPlay, Подбодрите пострадавшего. Скажите пострадавшему, что с ним будет все в порядке и что вы {enter}
SendPlay, {T}
sleep 2000
SendPlay, оказываете ему помощь. Ободрение — это важно. Попросите человека, чтобы он с вами {enter}
SendPlay, {T}
sleep 2000
SendPlay, разговаривал. Не дайте пострадавшему мерзнуть. {enter}
SendPlay, {T}
sleep 2000
SendPlay, Оставайтесь с человеком. Успокаивайте и согревайте пострадавшего. Дождитесь представителей {enter}
SendPlay, {T}
sleep 2000
SendPlay, власти. Если вокруг пулевого ранения кровь свернулась, то не удаляйте ее, поскольку она действует {enter}
SendPlay, {T}
sleep 2000
SendPlay, как пробка, не позволяя крови вытекать. {enter}
SendPlay, {T}
sleep 2000
SendPlay, Лекция завершена.{enter}
sleep 111
sendplay {f12}
}
return

:*?:лекпмпв::
{
Sendmessage, 0x50,, 0x4190419,, A
sleep 300
SendPlay, Сейчас будет проведена лекция "Первая помощь при вывихе".{enter}
SendPlay, {T}
sleep 2000
SendPlay,  Вывих - смещение кости в суставе из нормального положения. {enter}
SendPlay, {T}
sleep 2000
SendPlay, Если суставные поверхности костей перестают соприкасаться друг с другом, то вывих {enter}
SendPlay, {T}
sleep 2000
SendPlay, называется полным. {enter}
SendPlay, {T}
sleep 2000
SendPlay,  Если сохраняется частичное соприкосновение костей, то вывих считается неполным - подвывих. {enter}
SendPlay, {T}
sleep 2000
SendPlay,  Симптомы вывихов:  {enter}
SendPlay, {T}
sleep 2000
SendPlay,  1. Сильная боль в области сустава;  {enter}
SendPlay, {T}
sleep 2000
SendPlay, 2. Конечностью либо невозможно двигать, либо это получается с большим трудом;{enter}
SendPlay, {T}
sleep 2000
SendPlay, 3. Сустав имеет необычный вид, конечность принимает неестественное положение.{enter}
SendPlay, {T}
sleep 2000
SendPlay, Оказание первой помощи при вывихах заключается в 4-х действиях:{enter}
SendPlay, {T}
sleep 2000
SendPlay, Обеспечить покой пострадавшему, убедить его не двигать травмированной конечностью; {enter}
SendPlay, {T}
sleep 2000
SendPlay, Приложить на травмированную зону что-нибудь холодное на 20 минут;{enter}
SendPlay, {T}
sleep 2000
SendPlay,  Зафиксировав повреждённую конечность, доставить пострадавшего в мед. учреждение; {enter}
SendPlay, {T}
sleep 2000
SendPlay, Сделать рентген, если вывих подтвердился, то нужно вправить его, предварительно дав пациенту {enter}
SendPlay, {T}
sleep 2000
SendPlay, обезболивающее и мазь. {enter}
SendPlay, {T}
sleep 2000
SendPlay, Для иммобилизации руки её подвешивают на бинт или косынку, а для фиксации ноги лучше {enter}
SendPlay, {T}
sleep 2000
SendPlay, наложить шину, также как при переломе.{enter}
SendPlay, {T}
sleep 2000
SendPlay, Лекция завершена.{enter}
sleep 111
sendplay {f12}
}
return

:*?:леквст::
{
Sendmessage, 0x50,, 0x4190419,, A
sleep 300
SendPlay,  Приветствую. Эта лекция предназначена для только что поступивших сотрудников.{enter}
SendPlay, {T}
sleep 2000
SendPlay, /b Лекция является наиболее важной. Пожалуйста, внимательно прочитайте ее, а не проигнорируйте. {enter}
SendPlay, {T}
sleep 2000
SendPlay, Вы — интерны или фельдшеры, то есть начинающие врачи, которые в будущем смогут лечить пациентов {enter}
SendPlay, {T}
sleep 2000
SendPlay, от различных болезней. Вам нужно научиться всему самому необходимому для интересной и {enter}
SendPlay, {T}
sleep 2000
SendPlay,  качественной работы. Начнём с рации. {enter}
SendPlay, {T}
sleep 2000
SendPlay,  /b /r — РП рация (только РП доклады с ТЕГами), /rb — НонРП рация (свободное общение без матов).  {enter}
SendPlay, {T}
sleep 2000
SendPlay, /b Существуют и другие рации, но эти являются основными. Подробнее о рациях написано на форуме.{enter}
SendPlay, {T}
sleep 2000
SendPlay, В рации запрещено свободно общаться и засорять эфир ненужными сообщениями. Доклады должны {enter}
SendPlay, {T}
sleep 2000
SendPlay, начинаться с ТЕГа сотрудника. Тег зависит от вашего отделения.{enter}
SendPlay, {T}
sleep 2000
SendPlay, /b Пример доклада: /r [тег] Заступил на смену.{enter}
SendPlay, {T}
sleep 2000
SendPlay, Одним из важных пунктов для работы является знание и понимание основных документов {enter}
SendPlay, {T}
sleep 2000
SendPlay, ПоМЗ — Положение о МЗ, основной уставной документ, с которым должен быть {enter}
SendPlay, {T}
sleep 2000
SendPlay,  ознакомлен каждый сотрудник. Кроме того, на государственном портале есть специальные {enter}
SendPlay, {T}
sleep 2000
SendPlay, информационные разделы, предназначенные для изучения основной информации. {enter}
SendPlay, {T}
sleep 2000
SendPlay, /b После приглашения в беседы обязательно изучите все закрепленные сообщения.{enter}
SendPlay, {T}
sleep 2000
SendPlay, /b Там есть вся необходимая {enter}
SendPlay, {T}
sleep 2000
SendPlay, /b информация для работы, в том числе и ссылки на устав,{enter}
SendPlay, {T}
sleep 2000
SendPlay,  /b бинды и критерии для повышения (и не только).{enter}
SendPlay, {T}
sleep 2000
SendPlay, Несмотря на то что вы уже являетесь практически полноценными врачами, интернам нельзя садиться {enter}
SendPlay, {T}
sleep 2000
SendPlay, за руль кареты СМП, проводить операции (нужно звать старших) и лечить пациентов{enter}
SendPlay, {T}
sleep 2000
SendPlay, с сильными осложнениями. Для повышения на должность фельдшера интернам необходимо {enter}
SendPlay, {T}
sleep 2000
SendPlay, пройти обучение в мед. институте, а фельдшерам выполнить критерии для повышения. {enter}
SendPlay, {T}
sleep 2000
SendPlay, Поговорим о рабочем дне: во время него запрещено снимать форму и заниматься своими делами. {enter}
SendPlay, {T}
sleep 2000
SendPlay, Исключения — перерыв на обед, выходной и дополнительный перерыв до 30 минут. {enter}
SendPlay, {T}
sleep 2000
SendPlay, /b пн-пт — 10:00-19:00, перерыв с 13:00 до 14:00; сб, вс — выходной.{enter}
SendPlay, {T}
sleep 2000
SendPlay, /b Вы должны находиться на смене не менее 5 реал. часов каждую неделю{enter}
SendPlay, {T}
sleep 2000
SendPlay, /b Если нет возможности отыграть норму, то нужно сообщить об этом в обсуждении группы.{enter}
SendPlay, {T}
sleep 2000
SendPlay, /b Кроме того, у нас есть журнал активности — слежка за онлайном сотрудников. При входе на сервер{enter}
SendPlay, {T}
sleep 2000
SendPlay, /b вам необходимо поставить статус !онлайн, при уходе со смены/во время перерыва — !афк,{enter}
SendPlay, {T}
sleep 2000
SendPlay, /b при выходе с сервера — !вышел (оффлайн). У нас есть специальная беседа,{enter} 
SendPlay, {T}
sleep 2000
SendPlay, /b там про это подробно расписано.{enter}
SendPlay, {T}
sleep 2000
SendPlay, /b при входе на сервер должен присутствовать доклад в рацию: /r [тег] Заступил на смену.{enter}
SendPlay, {T}
sleep 2000
SendPlay, /b при снятии формы (уходе со смены): /r [тег] Сдал смену. (все доклады есть на форуме).{enter}
SendPlay, {T}
sleep 2000
SendPlay, /b Информация, озвученная выше, есть в закрепленных сообщениях бесед. Обязательно изучите.{enter}
SendPlay, {T}
sleep 2000
SendPlay, На этом лекция подходит к концу. Если в процессе работы у вас возникнут какие-либо вопросы —{enter}
SendPlay, {T}
sleep 2000
SendPlay, смело задавайте, ничего не бойтесь. Желаю удачи.{enter}
SendPlay, {T}
sleep 2000
SendPlay, /b Можете заскринить лекцию для отчета с /timestamp или временем над HUD'ом (скринить — F12){enter}
sleep 111
sendplay {f12}
}
return
