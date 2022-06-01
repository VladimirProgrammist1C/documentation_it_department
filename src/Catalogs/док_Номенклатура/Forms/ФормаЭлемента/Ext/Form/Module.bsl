﻿
&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	док_ОбщегоНазначения.ЗаполнитьЗначенияЗаполненияПриСозданииНаСервере(Объект,Параметры.ЗначенияЗаполнения);
	УстановитьВидимостьКомплектующих();
КонецПроцедуры

&НаКлиенте
Процедура ТипПриИзменении(Элемент)
	УстановитьВидимостьКомплектующих();
КонецПроцедуры

&НаСервере
Процедура УстановитьВидимостьКомплектующих()
	Элементы.Вид.Видимость = Объект.Тип = Перечисления.док_ТипНоменклатуры.Комплектующие;		
КонецПроцедуры
