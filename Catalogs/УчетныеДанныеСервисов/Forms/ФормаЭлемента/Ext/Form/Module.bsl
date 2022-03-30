﻿
&НаКлиенте
Процедура НазначитьНаименование(Элемент)
	Объект.Наименование = "" + Объект.Сервис + " (" + Объект.Клиент + ")";
	УстановитьЗаголовокСсылки();
КонецПроцедуры

&НаКлиенте
Процедура ОткрытьСсылку(Команда)
	ПерейтиПоНавигационнойСсылке("https://" + элементы.ОткрытьСсылку.Заголовок);
КонецПроцедуры

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	УстановитьЗаголовокСсылки();
КонецПроцедуры

&НаСервере
Процедура УстановитьЗаголовокСсылки()
	Элементы.ОткрытьСсылку.Видимость = НЕ ПустаяСтрока(Объект.Сервис.URL);
	Элементы.ОткрытьСсылку.Заголовок = Строка(Объект.Сервис.URL);
КонецПроцедуры
