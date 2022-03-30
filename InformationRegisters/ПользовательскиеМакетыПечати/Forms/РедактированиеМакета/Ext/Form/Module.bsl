﻿///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2021, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	Если Параметры.ТабличныйДокумент <> Неопределено Тогда
		ИзменяемыйМакет = Параметры.ТабличныйДокумент;
	КонецЕсли;
	
	ИмяОбъектаМетаданныхМакета = Параметры.ИмяОбъектаМетаданныхМакета;
	
	ЧастиИмени = СтрРазделить(ИмяОбъектаМетаданныхМакета, ".");
	ИмяМакета = ЧастиИмени[ЧастиИмени.ВГраница()];
	
	ИмяВладельца = "";
	Для НомерЧасти = 0 По ЧастиИмени.ВГраница()-1 Цикл
		Если Не ПустаяСтрока(ИмяВладельца) Тогда
			ИмяВладельца = ИмяВладельца + ".";
		КонецЕсли;
		ИмяВладельца = ИмяВладельца + ЧастиИмени[НомерЧасти];
	КонецЦикла;
	
	ТипМакета = Параметры.ТипМакета;
	ПредставлениеМакета = ПредставлениеМакета();
	ИмяФайлаМакета = ОбщегоНазначенияКлиентСервер.ЗаменитьНедопустимыеСимволыВИмениФайла(ПредставлениеМакета) + "." + НРег(ТипМакета);
	
	Если Параметры.ТолькоОткрытие Тогда
		Заголовок = НСтр("ru = 'Открытие макета печатной формы'");
	КонецЕсли;
	
	ТипКлиента = ?(ОбщегоНазначения.ЭтоВебКлиент(), "", "Не") + "ВебКлиент";
	
	Если Не ОбщегоНазначения.ЭтоВебКлиент() И Не ОбщегоНазначения.ЭтоМобильныйКлиент() И ТипМакета = "MXL" Тогда
		Элементы.НадписьЗавершениеИзмененияНеВебКлиент.Заголовок = НСтр(
			"ru = 'После внесения необходимых изменений в макет нажмите на кнопку ""Завершить изменение""'");
	КонецЕсли;
	
	УстановитьНазваниеПрограммыДляОткрытияМакета();
	
	Элементы.Диалог.ТекущаяСтраница = Элементы["СтраницаЗагрузкаНаКомпьютер" + ТипКлиента];
	Элементы.КоманднаяПанель.ТекущаяСтраница = Элементы.ПанельЗагрузка;
	Элементы.КнопкаИзменить.КнопкаПоУмолчанию = Истина;
	
	Если ОбщегоНазначения.ЭтоМобильныйКлиент() Тогда 
		ТипКлиента = "МобильныйКлиент";
	КонецЕсли;
	КлючСохраненияПоложенияОкна = ТипКлиента + ВРег(ТипМакета);
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	#Если Не ВебКлиент И НЕ МобильныйКлиент Тогда
		Если Параметры.ТолькоОткрытие Тогда
			Отказ = Истина;
		КонецЕсли;
		Если Параметры.ТолькоОткрытие Или ТипМакета = "MXL" Тогда
			ОткрытьМакет();
		КонецЕсли;
	#КонецЕсли
КонецПроцедуры

&НаКлиенте
Процедура ПриЗакрытии(ЗавершениеРаботы)
	
	Если Не ПустаяСтрока(ИмяВременногоКаталога) Тогда
		НачатьУдалениеФайлов(Новый ОписаниеОповещения, ИмяВременногоКаталога);
	КонецЕсли;
	
	Если ЗавершениеРаботы Тогда
		Возврат;
	КонецЕсли;
	
	ИмяСобытия = "ОтказОтИзмененияМакета";
	Если МакетЗагружен Тогда
		ИмяСобытия = "Запись_ПользовательскиеМакетыПечати";
	КонецЕсли;
	
	Оповестить(ИмяСобытия, Новый Структура("ИмяОбъектаМетаданныхМакета", ИмяОбъектаМетаданныхМакета), ЭтотОбъект);
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовШапкиФормы

&НаКлиенте
Процедура СсылкаНаСтраницуПрограммыНажатие(Элемент)
	ФайловаяСистемаКлиент.ОткрытьНавигационнуюСсылку(АдресПрограммыДляОткрытияМакета);
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура Изменить(Команда)
	ОткрытьМакет();
	Если Параметры.ТолькоОткрытие Тогда
		Закрыть();
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура ЗавершитьИзменение(Команда)
	
	#Если Вебклиент ИЛИ МобильныйКлиент Тогда
		ОписаниеОповещения = Новый ОписаниеОповещения("ПриЗагрузкеФайла", ЭтотОбъект);
		ПараметрыЗагрузки = ФайловаяСистемаКлиент.ПараметрыЗагрузкиФайла();
		ПараметрыЗагрузки.ИдентификаторФормы = УникальныйИдентификатор;
		ФайловаяСистемаКлиент.ЗагрузитьФайл(ОписаниеОповещения, ПараметрыЗагрузки);
	#Иначе
		Если НРег(ТипМакета) = "mxl" Тогда
			ИзменяемыйМакет.Скрыть();
			АдресФайлаМакетаВоВременномХранилище = ПоместитьВоВременноеХранилище(ИзменяемыйМакет);
			МакетЗагружен = Истина;
		Иначе
			Файл = Новый Файл(ПутьКФайлуМакета);
			Если Файл.Существует() Тогда
				ДвоичныеДанные = Новый ДвоичныеДанные(ПутьКФайлуМакета);
				АдресФайлаМакетаВоВременномХранилище = ПоместитьВоВременноеХранилище(ДвоичныеДанные);
				МакетЗагружен = Истина;
			КонецЕсли;
		КонецЕсли;
		ЗаписатьМакетИЗакрыть();
	#КонецЕсли
	
КонецПроцедуры


&НаКлиенте
Процедура Отмена(Команда)
	Закрыть();
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаСервере
Процедура УстановитьНазваниеПрограммыДляОткрытияМакета()
	
	НазваниеПрограммыДляОткрытияМакета = "";
	
	ТипФайла = НРег(ТипМакета);
	Если ТипФайла = "mxl" Тогда
		НазваниеПрограммыДляОткрытияМакета = НСтр("ru = '""1С:Предприятие - Работа с файлами""'");
		АдресПрограммыДляОткрытияМакета = "http://v8.1c.ru/metod/fileworkshop.htm";
	ИначеЕсли ТипФайла = "doc" Тогда
		НазваниеПрограммыДляОткрытияМакета = НСтр("ru = '""Microsoft Word""'");
		АдресПрограммыДляОткрытияМакета = "http://office.microsoft.com/ru-ru/word";
	ИначеЕсли ТипФайла = "odt" Тогда
		НазваниеПрограммыДляОткрытияМакета = НСтр("ru = '""OpenOffice Writer""'");
		АдресПрограммыДляОткрытияМакета = "http://www.openoffice.org/product/writer.html";
	ИначеЕсли ТипФайла = "docx" Тогда
		НазваниеПрограммыДляОткрытияМакета = НСтр("ru = 'один из офисных пакетов или редактор документов формата Office Open XML'");
		АдресПрограммыДляОткрытияМакета = "";
	КонецЕсли;
	
	СведенияДляЗаполнения = Новый Структура;
	СведенияДляЗаполнения.Вставить("ИмяМакета", ПредставлениеМакета);
	СведенияДляЗаполнения.Вставить("НазваниеПрограммы", НазваниеПрограммыДляОткрытияМакета);
	СведенияДляЗаполнения.Вставить("ОписаниеДействия", ?(Параметры.ТолькоОткрытие, НСтр("ru = 'открытия'"), НСтр("ru = 'внесения изменений'")));
	
	ЗаполняемыеЭлементы = Новый Массив; // Массив из ДекорацияФормы
	ЗаполняемыеЭлементы.Добавить(Элементы.СсылкаНаСтраницуПрограммыПередЗагрузкойВебКлиент);
	ЗаполняемыеЭлементы.Добавить(Элементы.СсылкаНаСтраницуПрограммыПередЗагрузкойНеВебКлиент);
	ЗаполняемыеЭлементы.Добавить(Элементы.СсылкаНаСтраницуПрограммыЗавершениеИзмененияВебКлиент);
	ЗаполняемыеЭлементы.Добавить(Элементы.СсылкаНаСтраницуПрограммыЗавершениеИзмененияНеВебКлиент);
	ЗаполняемыеЭлементы.Добавить(Элементы.НадписьПередЗагрузкойМакетаПрограммаВебКлиент);
	ЗаполняемыеЭлементы.Добавить(Элементы.НадписьПередЗагрузкойМакетаПрограммаНеВебКлиент);
	ЗаполняемыеЭлементы.Добавить(Элементы.НадписьЗавершениеИзмененияВебКлиент);
	ЗаполняемыеЭлементы.Добавить(Элементы.НадписьЗавершениеИзмененияНеВебКлиент);
	
	Для Каждого Элемент Из ЗаполняемыеЭлементы Цикл
		Элемент.Заголовок = СтроковыеФункцииКлиентСервер.ВставитьПараметрыВСтроку(Элемент.Заголовок, СведенияДляЗаполнения);
	КонецЦикла;
	
	ВидимостьСсылкиНаСтраницуПрограммы = (ОбщегоНазначения.ЭтоВебКлиент() Или ТипФайла <> "mxl") И ТипФайла <> "docx";
	Элементы.СсылкаНаСтраницуПрограммыПередЗагрузкойВебКлиент.Видимость = ВидимостьСсылкиНаСтраницуПрограммы;
	Элементы.СсылкаНаСтраницуПрограммыПередЗагрузкойНеВебКлиент.Видимость = ВидимостьСсылкиНаСтраницуПрограммы;
	Элементы.СсылкаНаСтраницуПрограммыЗавершениеИзмененияВебКлиент.Видимость = ВидимостьСсылкиНаСтраницуПрограммы;
	Элементы.СсылкаНаСтраницуПрограммыЗавершениеИзмененияНеВебКлиент.Видимость = ВидимостьСсылкиНаСтраницуПрограммы;
	
	Элементы.НадписьПередЗагрузкойМакетаПрограммаНеВебКлиент.Видимость = ТипФайла <> "mxl";
	
	Элементы.СтраницаЗагрузкаНаКомпьютерВебКлиент.Видимость = ОбщегоНазначения.ЭтоВебКлиент();
	Элементы.СтраницаЗагрузкаВИнформационнуюБазуВебКлиент.Видимость = ОбщегоНазначения.ЭтоВебКлиент();
	Элементы.СтраницаЗагрузкаНаКомпьютерНеВебКлиент.Видимость = Не ОбщегоНазначения.ЭтоВебКлиент();
	Элементы.СтраницаЗагрузкаВИнформационнуюБазуНеВебКлиент.Видимость = Не ОбщегоНазначения.ЭтоВебКлиент();
	
КонецПроцедуры

&НаСервере
Функция ПредставлениеМакета()
	
	Результат = ИмяМакета;
	
	Владелец = Метаданные.НайтиПоПолномуИмени(ИмяВладельца);
	Если Владелец <> Неопределено Тогда
		Макет = Владелец.Макеты.Найти(ИмяМакета);
		Если Макет <> Неопределено Тогда
			Результат = Макет.Синоним;
		КонецЕсли;
	КонецЕсли;
	
	Возврат Результат;
	
КонецФункции

&НаКлиенте
Процедура ОткрытьМакет()
	#Если ВебКлиент ИЛИ МобильныйКлиент Тогда
		ОткрытьМакетВебКлиент();
	#Иначе
		ОткрытьМакетТонкийКлиент();
	#КонецЕсли
КонецПроцедуры

&НаКлиенте
Процедура ОткрытьМакетТонкийКлиент()
	
	ОписаниеОповещения = Новый ОписаниеОповещения("ОткрытьМакетТонкийКлиентПослеСозданияВременногоКаталога", ЭтотОбъект);
	ФайловаяСистемаКлиент.СоздатьВременныйКаталог(ОписаниеОповещения);
	
КонецПроцедуры

&НаКлиенте
Процедура ОткрытьМакетТонкийКлиентПослеСозданияВременногоКаталога(ИмяВременногоКаталога, ДополнительныеПараметры) Экспорт
	
#Если Не ВебКлиент И НЕ МобильныйКлиент Тогда
	Макет = МакетПечатнойФормы(ИмяОбъектаМетаданныхМакета);
	ПутьКФайлуМакета = ОбщегоНазначенияКлиентСервер.ДобавитьКонечныйРазделительПути(ИмяВременногоКаталога) + ИмяФайлаМакета;
	
	Если ТипМакета = "MXL" Тогда
		Если Параметры.ТолькоОткрытие Тогда
			Макет.ТолькоПросмотр = Истина;
			Макет.Показать(ПредставлениеМакета,,Истина);
		Иначе
			Макет.Записать(ПутьКФайлуМакета);
			Макет.Показать(ПредставлениеМакета, ПутьКФайлуМакета, Истина);
			
			ИзменяемыйМакет = Макет;
		КонецЕсли;
	Иначе
		Макет.Записать(ПутьКФайлуМакета);
		Если Параметры.ТолькоОткрытие Тогда
			ФайлМакета = Новый Файл(ПутьКФайлуМакета);
			ФайлМакета.УстановитьТолькоЧтение(Истина);
		КонецЕсли;
		ФайловаяСистемаКлиент.ОткрытьФайл(ПутьКФайлуМакета);
	КонецЕсли;
	
	ПерейтиНаСтраницуЗавершенияИзменения();
#КонецЕсли
	
КонецПроцедуры

&НаКлиенте
Процедура ОткрытьМакетВебКлиент()
	ФайловаяСистемаКлиент.СохранитьФайл(Неопределено, ПоместитьМакетВоВременноеХранилище(), ИмяФайлаМакета);
	ПерейтиНаСтраницуЗавершенияИзменения();
КонецПроцедуры

&НаСервере
Функция ПоместитьМакетВоВременноеХранилище()
	
	Возврат ПоместитьВоВременноеХранилище(ДвоичныеДанныеМакета(), УникальныйИдентификатор);
	
КонецФункции

&НаСервере
Функция ДвоичныеДанныеМакета()
	
	ДанныеМакета = ИзменяемыйМакет;
	Если ИзменяемыйМакет.ВысотаТаблицы = 0 Тогда
		ДанныеМакета = УправлениеПечатью.МакетПечатнойФормы(ИмяОбъектаМетаданныхМакета);
	КонецЕсли;
	
	Если ТипЗнч(ДанныеМакета) = Тип("ТабличныйДокумент") Тогда
		ИмяВременногоФайла = ПолучитьИмяВременногоФайла();
		ДанныеМакета.Записать(ИмяВременногоФайла);
		ДанныеМакета = Новый ДвоичныеДанные(ИмяВременногоФайла);
		УдалитьФайлы(ИмяВременногоФайла);
	КонецЕсли;
	
	Возврат ДанныеМакета;
	
КонецФункции

&НаКлиенте
Процедура ПерейтиНаСтраницуЗавершенияИзменения()
	Элементы.Диалог.ТекущаяСтраница = Элементы["СтраницаЗагрузкаВИнформационнуюБазу" + ТипКлиента];
	Элементы.КоманднаяПанель.ТекущаяСтраница = Элементы.ПанельЗавершениеИзменения;
	Элементы.КнопкаЗавершитьИзменение.КнопкаПоУмолчанию = Истина;
КонецПроцедуры

&НаСервере
Функция МакетИзВременногоХранилища()
	Макет = ПолучитьИзВременногоХранилища(АдресФайлаМакетаВоВременномХранилище); // ТабличныйДокумент - 
	Если НРег(ТипМакета) = "mxl" И ТипЗнч(Макет) <> Тип("ТабличныйДокумент") Тогда
		ИмяВременногоФайла = ПолучитьИмяВременногоФайла();
		Макет.Записать(ИмяВременногоФайла);
		ТабличныйДокумент = Новый ТабличныйДокумент;
		ТабличныйДокумент.Прочитать(ИмяВременногоФайла);
		Макет = ТабличныйДокумент;
		УдалитьФайлы(ИмяВременногоФайла);
	КонецЕсли;
	Возврат Макет;
КонецФункции

&НаСервере
Процедура ЗаписатьМакет(Макет)
	Запись = РегистрыСведений.ПользовательскиеМакетыПечати.СоздатьМенеджерЗаписи();
	Запись.Объект = ИмяВладельца;
	Запись.ИмяМакета = ИмяМакета;
	Запись.Использование = Истина;
	Запись.Макет = Новый ХранилищеЗначения(Макет, Новый СжатиеДанных(9));
	Запись.Записать();
КонецПроцедуры

&НаСервереБезКонтекста
Функция МакетПечатнойФормы(ИмяОбъектаМетаданныхМакета)
	
	Макет = УправлениеПечатью.МакетПечатнойФормы(ИмяОбъектаМетаданныхМакета);
	Если ТипЗнч(Макет) = Тип("ТабличныйДокумент") Или ТипЗнч(Макет) = Тип("ДвоичныеДанные") Тогда
		Возврат Макет;
	КонецЕсли;
	
	ВызватьИсключение НСтр("ru = 'Открытие данного макета для просмотра или редактирования не предусмотрено.'");
	
КонецФункции

&НаКлиенте
Процедура ПриЗагрузкеФайла(Файл, ДополнительныеПараметры) Экспорт
	
	МакетЗагружен = Файл <> Неопределено;
	Если МакетЗагружен Тогда
		АдресФайлаМакетаВоВременномХранилище = Файл.Хранение;
		ИмяФайлаМакета = Файл.Имя;
	КонецЕсли;
	
	ЗаписатьМакетИЗакрыть();
	
КонецПроцедуры

&НаКлиенте
Процедура ЗаписатьМакетИЗакрыть()
	Макет = Неопределено;
	Если МакетЗагружен Тогда
		Макет = МакетИзВременногоХранилища();
		Если Не ЗначениеЗаполнено(Параметры.ТабличныйДокумент) Тогда
			ЗаписатьМакет(Макет);
		КонецЕсли;
	КонецЕсли;
	
	Закрыть(Макет);
КонецПроцедуры

#КонецОбласти
