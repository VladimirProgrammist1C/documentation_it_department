﻿ 
&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	ВидимостьТипПодключения();
КонецПроцедуры

&НаКлиенте
Процедура ТипПодключенияПриИзменении(Элемент)
	ВидимостьТипПодключения();
КонецПроцедуры

&НаСервере
Процедура ВидимостьТипПодключения()
	Элементы.IP.Видимость = Объект.Тип = Перечисления.ТипПодключения.Сетевой;
КонецПроцедуры
