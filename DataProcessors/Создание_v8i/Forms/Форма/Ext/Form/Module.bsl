﻿
&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	Если Параметры.Свойство("Ключ") Тогда
		Объект.БД = Параметры.Ключ;
		ЭтаФорма.АвтоЗаголовок = Ложь;
		ЭтаФорма.ОтображатьЗаголовок = Ложь;
	Конецесли;	
	DisableSplash = Истина;
	
КонецПроцедуры

&НаКлиенте
Процедура СоздатьФайл(Команда)
	
	Текст = "";
	СоздатьТекстНаСервере(Текст);
	
	ДиалогСохраненияФайла = Новый ДиалогВыбораФайла(РежимДиалогаВыбораФайла.Сохранение); 
	ДиалогСохраненияФайла.ПолноеИмяФайла = Строка(Объект.БД); 
	Фильтр = "Общий список информационных баз (*.v8i)|*.v8i";                 
	ДиалогСохраненияФайла.Фильтр = Фильтр; 
	ДиалогСохраненияФайла.МножественныйВыбор = Ложь; 
	ДиалогСохраненияФайла.Заголовок = "Выберите путь и имя файла"; 
	
	ОписаниеОповещения = Новый ОписаниеОповещения("ПослеСохраненияФайла",ЭтаФорма,ДиалогСохраненияФайла);
	ФайловаяСистемаКлиент.ПоказатьДиалогВыбора(ОписаниеОповещения,ДиалогСохраненияФайла);	
	
КонецПроцедуры

&НаКлиенте
Процедура ПослеСохраненияФайла(ВыбранныеФайлы, Параметры) Экспорт
	
	Если Не ЗначениеЗаполнено(ВыбранныеФайлы) Тогда
		Возврат;
	КонецЕсли;
	
	ТекстДок = Новый ТекстовыйДокумент;
	ТекстДок.ДобавитьСтроку(Текст);
	ТекстДок.НачатьЗапись(,ВыбранныеФайлы[0]);
	
КонецПроцедуры

&НаСервере
Процедура СоздатьТекстНаСервере(Текст)
	
	Текст = "[" + Объект.БД.Наименование + "]" + Символы.ПС;
	Если Объект.БД.ТипБД = Перечисления.ТипБД.Файловая Тогда
		Текст = Текст + "Connect=File=""" + Объект.БД.ПутьК_БД + """";
	Иначе	
		Текст = Текст + "Connect=Srvr=""" + Объект.БД.СУБД.Наименование + """;Ref=""" + Объект.БД.ИмяИБ + """" + Символы.ПС;
	КонецЕсли;	
	Текст = Текст + ?(НЕ ClientConnectionSpeed = "","ClientConnectionSpeed=" + ClientConnectionSpeed + Символы.ПС, "");
	Текст = Текст + ?(НЕ App = "","App=" + App + Символы.ПС, "");
	Текст = Текст + ?(WA,"WA=1" + Символы.ПС, "");
	Текст = Текст + ?(НЕ Version = "","Version=" + Version + Символы.ПС, "");
	Текст = Текст + ?(DisableSplash,"DisableSplash=1" + Символы.ПС, "");
	
КонецПроцедуры