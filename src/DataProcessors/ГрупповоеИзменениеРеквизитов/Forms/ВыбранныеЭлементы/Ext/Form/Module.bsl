﻿///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2023, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	ВыбранныеТипы = Параметры.ВыбранныеТипы;
	КлючНазначенияИспользования = СократитьСтрокуКонтрольнойСуммой(ВыбранныеТипы, 128);
	
	ОбъектОбработка = РеквизитФормыВЗначение("Объект");
	ТекстЗапроса = ОбъектОбработка.ТекстЗапроса(ВыбранныеТипы);
	
	ИнициализироватьКомпоновщикНастроек();
	КомпоновщикНастроек.ЗагрузитьНастройки(Параметры.Настройки);
	
	Список.ТекстЗапроса = ТекстЗапроса;
	
	ОбновитьСписокВыбранныхНаСервере();
	
КонецПроцедуры

&НаСервере
Процедура ПриСохраненииДанныхВНастройкахНаСервере(Настройки)
	Настройки["Отбор"] = НастройкиКомпоновкиДанных();
КонецПроцедуры

&НаСервере
Процедура ПриЗагрузкеДанныхИзНастроекНаСервере(Настройки)
	НастройкиКомпоновки = Настройки["Отбор"];
	Если НастройкиКомпоновки <> Неопределено Тогда
		КомпоновщикНастроек.ЗагрузитьНастройки(НастройкиКомпоновки);
		ОбновитьСписокВыбранныхНаСервере();
	КонецЕсли;	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовТаблицыФормыКомпоновщикНастроекНастройкиОтбор

&НаКлиенте
Процедура КомпоновщикНастроекНастройкиОтборПриНачалеРедактирования(Элемент, НоваяСтрока, Копирование)
	
	ОтключитьОбработчикОжидания("ОбновитьКоличествоВыбранных");
	ОтключитьОбработчикОжидания("ОбновитьСписокВыбранных");
	ВыполняетсяРедактированиеОтборов = Истина;
	
КонецПроцедуры

&НаКлиенте
Процедура КомпоновщикНастроекНастройкиОтборПриОкончанииРедактирования(Элемент, НоваяСтрока, ОтменаРедактирования)
	
	ВыполняетсяРедактированиеОтборов = Ложь;
	ИнициализироватьОбновлениеСпискаВыбранных();
	
КонецПроцедуры

&НаКлиенте
Процедура КомпоновщикНастроекНастройкиОтборПослеУдаления(Элемент)
	
	ИнициализироватьОбновлениеСпискаВыбранных();
	
КонецПроцедуры

&НаКлиенте
Процедура КомпоновщикНастроекНастройкиОтборПередНачаломДобавления(Элемент, Отказ, Копирование, Родитель, Группа)
	
	ОтключитьОбработчикОжидания("ОбновитьКоличествоВыбранных");
	ОтключитьОбработчикОжидания("ОбновитьСписокВыбранных");
	
КонецПроцедуры

&НаКлиенте
Процедура КомпоновщикНастроекНастройкиОтборПриАктивизацииСтроки(Элемент)
	
	КоличествоЭлементовОтбора = КоличествоЭлементовОтбора(КомпоновщикНастроек.Настройки.Отбор.Элементы);
	Если КоличествоУсловий <> КоличествоЭлементовОтбора Тогда
		ИнициализироватьОбновлениеСпискаВыбранных();
	КонецЕсли; 
	
КонецПроцедуры

&НаКлиенте
Процедура КомпоновщикНастроекНастройкиОтборПриИзменении(Элемент)
	
	ИнициализироватьОбновлениеСпискаВыбранных();
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовТаблицыФормыСписок

&НаКлиенте
Процедура СписокВыбор(Элемент, ВыбраннаяСтрока, Поле, СтандартнаяОбработка)
	Если Элемент.ТекущиеДанные <> Неопределено Тогда 
		ПоказатьЗначение(, Элемент.ТекущиеДанные.Ссылка);
	КонецЕсли;
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура ОК(Команда)
	ОтключитьОбработчикОжидания("ОбновитьСписокВыбранных");
	Результат = НастройкиКомпоновкиДанных();
	Закрыть(Результат);
КонецПроцедуры

&НаСервере
Функция НастройкиКомпоновкиДанных()
	Если Элементы.ГруппаВыбранныеОбъекты.Видимость Тогда
		ОбновитьСписокВыбранныхНаСервере();
	КонецЕсли;
	Возврат Список.КомпоновщикНастроек.ПолучитьНастройки();
КонецФункции

&НаКлиенте
Процедура ОткрытьЭлемент(Команда)
	
	ТекущиеДанные = Элементы.Список.ТекущиеДанные;
	Если ТекущиеДанные = Неопределено Тогда
		Возврат;
	КонецЕсли;
	ПоказатьЗначение(, ТекущиеДанные.Ссылка);
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаСервере
Процедура ИнициализироватьКомпоновщикНастроек()
	Если Не ПустаяСтрока(Параметры.ВыбранныеТипы) Тогда
		СхемаКомпоновкиДанных = СхемаКомпоновкиДанных(ТекстЗапроса);
		АдресСхемы = ПоместитьВоВременноеХранилище(СхемаКомпоновкиДанных, УникальныйИдентификатор);
		КомпоновщикНастроек.Инициализировать(Новый ИсточникДоступныхНастроекКомпоновкиДанных(АдресСхемы));
	КонецЕсли;
КонецПроцедуры

&НаСервере
Функция СхемаКомпоновкиДанных(ТекстЗапроса)
	ОбработкаОбъект = РеквизитФормыВЗначение("Объект");
	Возврат ОбработкаОбъект.СхемаКомпоновкиДанных(ТекстЗапроса);
КонецФункции

&НаСервере
Процедура ОбновитьСписокВыбранныхНаСервере()
	
	Список.КомпоновщикНастроек.ЗагрузитьНастройки(КомпоновщикНастроек.Настройки);
	
	Структура = Список.КомпоновщикНастроек.Настройки.Структура;
	Структура.Очистить();
	ГруппировкаКомпоновкиДанных = Структура.Добавить(Тип("ГруппировкаКомпоновкиДанных"));
	ГруппировкаКомпоновкиДанных.Выбор.Элементы.Добавить(Тип("АвтоВыбранноеПолеКомпоновкиДанных"));
	ГруппировкаКомпоновкиДанных.Использование = Истина;
	
	Выбор = Список.КомпоновщикНастроек.Настройки.Выбор;
	ПолеВыбора = Выбор.Элементы.Добавить(Тип("ВыбранноеПолеКомпоновкиДанных"));
	ПолеВыбора.Поле = Новый ПолеКомпоновкиДанных("Ссылка");
	ПолеВыбора.Использование = Истина;
	
	ОбновитьКоличествоВыбранныхСервер();

КонецПроцедуры

&НаКлиенте
Процедура ОбновитьКоличествоВыбранных()
	ОбновитьКоличествоВыбранныхСервер();
КонецПроцедуры
	
&НаСервере
Процедура ОбновитьКоличествоВыбранныхСервер()
	
	ПредыдущееКоличествоВыбранных = КоличествоВыбранных;
	
	КоличествоВыбранных = ВыбранныеОбъекты().Строки.Количество();
	ТекстКоличествоВыбранных = Строка(КоличествоВыбранных);
	Если КоличествоВыбранных > 1000 Тогда
		КоличествоВыбранных = 1000;
		ТекстКоличествоВыбранных = НСтр("ru = '> 1000';
										|en = '> 1000'");
	ИначеЕсли КоличествоВыбранных = 0 Тогда
		Список.КомпоновщикНастроек.Восстановить(СпособВосстановленияНастроекКомпоновкиДанных.Полное);
	КонецЕсли;
	Если ПредыдущееКоличествоВыбранных <> КоличествоВыбранных Тогда
		Элементы.ГруппаВыбранныеОбъекты.Заголовок = ПодставитьПараметрыВСтроку(
			НСтр("ru = 'Выбранные элементы (%1)';
				|en = 'Selected items (%1)'"), ТекстКоличествоВыбранных);
	КонецЕсли;

КонецПроцедуры

&НаКлиенте
Процедура ИнициализироватьОбновлениеСпискаВыбранных()
	
	ОтключитьОбработчикОжидания("ОбновитьСписокВыбранных");

	Если ВыполняетсяРедактированиеОтборов Тогда
		Возврат;
	КонецЕсли;
	
	КоличествоУсловий = КоличествоЭлементовОтбора(КомпоновщикНастроек.Настройки.Отбор.Элементы);
	
	Если Элементы.ГруппаВыбранныеОбъекты.Видимость Тогда
		ПодключитьОбработчикОжидания("ОбновитьСписокВыбранных", 1, Истина);
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ОбновитьСписокВыбранных()
	ОбновитьСписокВыбранныхНаСервере();
КонецПроцедуры

&НаСервере
Функция ВыбранныеОбъекты()
	
	Результат = Новый ДеревоЗначений;
	
	Если Не ПустаяСтрока(ВыбранныеТипы) Тогда
		СхемаКомпоновкиДанных = Элементы.Список.ПолучитьИсполняемуюСхемуКомпоновкиДанных();
		Настройки = Элементы.Список.ПолучитьИсполняемыеНастройкиКомпоновкиДанных();
		КомпоновщикМакета = Новый КомпоновщикМакетаКомпоновкиДанных();
		Попытка
			МакетКомпоновкиДанных = КомпоновщикМакета.Выполнить(СхемаКомпоновкиДанных,
				Настройки,,, Тип("ГенераторМакетаКомпоновкиДанныхДляКоллекцииЗначений"));
		Исключение
			Возврат Результат;
		КонецПопытки;
		
		ПроцессорКомпоновкиДанных = Новый ПроцессорКомпоновкиДанных;
		ПроцессорКомпоновкиДанных.Инициализировать(МакетКомпоновкиДанных);

		ПроцессорВывода = Новый ПроцессорВыводаРезультатаКомпоновкиДанныхВКоллекциюЗначений;
		ПроцессорВывода.УстановитьОбъект(Результат);
		ПроцессорВывода.Вывести(ПроцессорКомпоновкиДанных);
	КонецЕсли;
	
	Возврат Результат;
	
КонецФункции

&НаКлиентеНаСервереБезКонтекста
Функция ПодставитьПараметрыВСтроку(Знач СтрокаПодстановки,
	Знач Параметр1, Знач Параметр2 = Неопределено, Знач Параметр3 = Неопределено)
	
	СтрокаПодстановки = СтрЗаменить(СтрокаПодстановки, "%1", Параметр1);
	СтрокаПодстановки = СтрЗаменить(СтрокаПодстановки, "%2", Параметр2);
	СтрокаПодстановки = СтрЗаменить(СтрокаПодстановки, "%3", Параметр3);
	
	Возврат СтрокаПодстановки;
КонецФункции

&НаСервере
Функция СократитьСтрокуКонтрольнойСуммой(Строка, МаксимальнаяДлина)
	Результат = Строка;
	Если СтрДлина(Строка) > МаксимальнаяДлина Тогда
		Результат = Лев(Строка, МаксимальнаяДлина - 32);
		ХешированиеДанных = Новый ХешированиеДанных(ХешФункция.MD5);
		ХешированиеДанных.Добавить(Сред(Строка, МаксимальнаяДлина - 32 + 1));
		Результат = Результат + СтрЗаменить(ХешированиеДанных.ХешСумма, " ", "");
	КонецЕсли;
	Возврат Результат;
КонецФункции

&НаКлиенте
Функция КоличествоЭлементовОтбора(КоллекцияЭлементовОтбора)
	
	Результат = 0;
	
	Для Каждого Элемент Из КоллекцияЭлементовОтбора Цикл
		Результат = Результат + 1;
		Если ТипЗнч(Элемент) = Тип("ГруппаЭлементовОтбораКомпоновкиДанных") Тогда
			Результат = Результат + КоличествоЭлементовОтбора(Элемент.Элементы);
		КонецЕсли;
	КонецЦикла;
	
	Возврат Результат;
	
КонецФункции

#КонецОбласти
