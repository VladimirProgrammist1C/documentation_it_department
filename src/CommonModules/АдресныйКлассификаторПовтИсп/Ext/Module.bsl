﻿///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2023, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область СлужебныйПрограммныйИнтерфейс

Функция ТипыАдресныхОбъектовДляРаспознаванияАдреса() Экспорт
	
	Запрос = Новый Запрос;
	Запрос.Текст =
	"ВЫБРАТЬ
	|	УровниСокращенийАдресныхСведений.Сокращение КАК Сокращение
	|ИЗ
	|	РегистрСведений.УровниСокращенийАдресныхСведений КАК УровниСокращенийАдресныхСведений";
	
	РезультатЗапроса = Запрос.Выполнить();
	
	Если РезультатЗапроса.Пустой() Тогда
		АдресныеСокращения = РегистрыСведений.АдресныеОбъекты.АдресныеСокращения();
	Иначе
		АдресныеСокращения = РезультатЗапроса.Выгрузить(); 
	КонецЕсли;
	
	АдресныеСокращения.Колонки.Добавить("Длина", ОбщегоНазначения.ОписаниеТипаЧисло(3));
	АдресныеСокращения.Колонки.Добавить("ТипОбъектаВНачале", ОбщегоНазначения.ОписаниеТипаСтрока(20));
	АдресныеСокращения.Колонки.Добавить("ТипОбъектаВКонце", ОбщегоНазначения.ОписаниеТипаСтрока(20));
	
	Для каждого ЭлементИзПеречня Из АдресныеСокращения Цикл
		ЭлементИзПеречня.ТипОбъектаВНачале = ВРег(ЭлементИзПеречня.Сокращение) + " ";
		ЭлементИзПеречня.ТипОбъектаВКонце = " " + ВРег(ЭлементИзПеречня.Сокращение);
		ЭлементИзПеречня.Длина = СтрДлина(ЭлементИзПеречня.Сокращение);
	КонецЦикла;
	
	АдресныеСокращения.Свернуть("Длина, ТипОбъектаВНачале, ТипОбъектаВКонце");

	АдресныеСокращения.Индексы.Добавить("Длина");
	АдресныеСокращения.Сортировать("Длина Убыв");
	
	Возврат АдресныеСокращения;
	
КонецФункции

Функция НаименованияВладенийИСтроений() Экспорт
	
	Результат = Новый Структура("Владения, Строения", Новый Соответствие, Новый Соответствие);
	Результат.Владения.Вставить(0, "Дом");
	Результат.Строения.Вставить(0, "Строение");
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	СлужебныеАдресныеСведения.Тип КАК Тип,
	|	СлужебныеАдресныеСведения.Идентификатор КАК Идентификатор,
	|	СлужебныеАдресныеСведения.Значение КАК Значение
	|ИЗ
	|	РегистрСведений.СлужебныеАдресныеСведения КАК СлужебныеАдресныеСведения
	|ГДЕ
	|	СлужебныеАдресныеСведения.Тип = ""ТипыВладений""
	|	ИЛИ СлужебныеАдресныеСведения.Тип = ""ТипыСтроений""
	|
	|УПОРЯДОЧИТЬ ПО
	|	Значение";
	
	РезультатЗапроса = Запрос.Выполнить().Выбрать();
	
	Пока РезультатЗапроса.Следующий() Цикл
		Если РезультатЗапроса.Тип = "ТипыВладений" Тогда
			Результат.Владения.Вставить(РезультатЗапроса.Идентификатор, РезультатЗапроса.Значение);
		ИначеЕсли РезультатЗапроса.Тип = "ТипыСтроений" Тогда
			Результат.Строения.Вставить(РезультатЗапроса.Идентификатор, РезультатЗапроса.Значение);
		КонецЕсли;
	КонецЦикла;
	
	Возврат Новый ФиксированнаяСтруктура(Результат);
	
КонецФункции

Функция НаименованияПомещений() Экспорт
	
	Результат = Новый Соответствие;
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	СлужебныеАдресныеСведения.Тип КАК Тип,
	|	СлужебныеАдресныеСведения.Идентификатор КАК Идентификатор,
	|	СлужебныеАдресныеСведения.Ключ КАК Ключ,
	|	СлужебныеАдресныеСведения.Значение КАК Значение
	|ИЗ
	|	РегистрСведений.СлужебныеАдресныеСведения КАК СлужебныеАдресныеСведения
	|ГДЕ
	|	СлужебныеАдресныеСведения.Тип = ""ТипыПомещений""
	|
	|УПОРЯДОЧИТЬ ПО
	|	Значение";
	
	РезультатЗапроса = Запрос.Выполнить().Выбрать();
	
	Пока РезультатЗапроса.Следующий() Цикл
		Результат.Вставить(РезультатЗапроса.Идентификатор, РезультатЗапроса.Значение);
	КонецЦикла;
	Результат.Вставить(0, "Этаж");
	
	Возврат Новый ФиксированноеСоответствие(Результат);
	
КонецФункции

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

// HTTPСоединение для вызова веб-сервиса 1С.
//
// Возвращаемое значение:
//     HTTPСоединение - объект для вызовов сервиса.
//
Функция СервисКлассификатора1С(ВремяОжидания = 120) Экспорт

	УстановитьПривилегированныйРежим(Истина);
	Авторизация = АдресныйКлассификаторСлужебный.ПараметрыАутентификацииНаСайте();
	УстановитьПривилегированныйРежим(Ложь);
	
	Если Авторизация = Неопределено Тогда
		ИмяПользователя    = "неавторизованный";
		ПарольПользователя = "";
	Иначе
		ИмяПользователя    = Авторизация.Логин;
		ПарольПользователя = Авторизация.Пароль;
	КонецЕсли;
	
	СтруктураURIВебСервиса = ОбщегоНазначенияКлиентСервер.СтруктураURI(АдресныйКлассификаторСлужебный.АдресВебСервисаКонтактнойИнформации());
	ИмяСервера = СтруктураURIВебСервиса.ИмяСервера;
	
	Порт = ?(ЗначениеЗаполнено(СтруктураURIВебСервиса.Порт), СтруктураURIВебСервиса.Порт, Неопределено);
	Прокси = Неопределено;
	
	Если ОбщегоНазначения.ПодсистемаСуществует("СтандартныеПодсистемы.ПолучениеФайловИзИнтернета") Тогда
		МодульПолучениеФайловИзИнтернета = ОбщегоНазначения.ОбщийМодуль("ПолучениеФайловИзИнтернета");
		Прокси = МодульПолучениеФайловИзИнтернета.ПолучитьПрокси(СтруктураURIВебСервиса.Схема);
	КонецЕсли;

	ЗащищенноеСоединение         = ОбщегоНазначенияКлиентСервер.НовоеЗащищенноеСоединение();
	ИспользоватьАутентификациюОС = Ложь;
	
	СохраненныйТекущийURLВебСервиса = ОбщегоНазначения.ХранилищеОбщихНастроекЗагрузить("АдресныйКлассификатор", "URLСервисаКлассификатора1С");
	Если ТипЗнч(СохраненныйТекущийURLВебСервиса) = Тип("Строка") И ЗначениеЗаполнено(СохраненныйТекущийURLВебСервиса) Тогда
		URLВебСервисаПоЧастям = СтрРазделить(СохраненныйТекущийURLВебСервиса, ":", Ложь);
		ИмяСервера = СокрЛП(URLВебСервисаПоЧастям[0]);
		Если URLВебСервисаПоЧастям.Количество() > 1 Тогда
			ТипЧисло = Новый ОписаниеТипов("Число");
			Порт = ТипЧисло.ПривестиЗначение(URLВебСервисаПоЧастям[1]);
			ЗащищенноеСоединение = Неопределено;
			Если Порт = 0 Тогда
				Порт = 80;
			КонецЕсли;
		КонецЕсли;
	КонецЕсли;
	
	УстановитьОтключениеБезопасногоРежима(Истина);
	
	Попытка
			
			Соединение = Новый HTTPСоединение(
				ИмяСервера,
				Порт,
				ИмяПользователя,
				ПарольПользователя,
				Прокси,
				ВремяОжидания,
				ЗащищенноеСоединение,
				ИспользоватьАутентификациюОС);
			
			Сервер = Соединение.Сервер;
			Порт   = Соединение.Порт;
			
	Исключение
		
		ШаблонЗапроса = "%1:%2%3ping";
		СсылкаНаРесурс = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(ШаблонЗапроса, ИмяСервера, Порт,
			АдресныйКлассификаторСлужебный.ПрефиксВерсииЗапроса());
		
		ТекстОшибки = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			НСтр("ru = 'Не удалось установить HTTP-соединение с сервером %1:%2
			           |по причине:
			           |%3';
			           |en = 'Cannot establish HTTP connection with server %1:%2
			           |due to:
			           |%3'"),
			Сервер, Формат(Порт, "ЧГ="),
			ОбработкаОшибок.КраткоеПредставлениеОшибки(ИнформацияОбОшибке()));
		
		Если ОбщегоНазначения.ПодсистемаСуществует("СтандартныеПодсистемы.ПолучениеФайловИзИнтернета") Тогда
			МодульПолучениеФайловИзИнтернета = ОбщегоНазначения.ОбщийМодуль("ПолучениеФайловИзИнтернета");
			РезультатДиагностики = МодульПолучениеФайловИзИнтернета.ДиагностикаСоединения(СсылкаНаРесурс);
			
			ТекстОшибки = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
				НСтр("ru = '%1
				           |Результат диагностики:
				           |%2';
				           |en = '%1
				           |Diagnostics result:
				           |%2'"),
				РезультатДиагностики.ОписаниеОшибки);
		КонецЕсли;
		
		ЗаписьЖурналаРегистрации(АдресныйКлассификаторСлужебный.СобытиеЖурналаРегистрации(), УровеньЖурналаРегистрации.Ошибка,,, ТекстОшибки);
		
	КонецПопытки;
	
	Возврат Соединение;
	
КонецФункции

Функция СведенияОЗагрузкеСубъектовРФ() Экспорт
	
	УстановитьПривилегированныйРежим(Истина);
	Результат = Новый Соответствие;
	
	// Веб-сервис 1С
	СервисРезультат = АдресныйКлассификаторСлужебный.ВерсияПоставщикаДанных();
	КлассификаторДоступен = (СервисРезультат.Данные = Истина);
	Результат.Вставить("КлассификаторДоступен", КлассификаторДоступен);
	
	ИспользоватьЗагруженные = Ложь;
	ЕстьЗагруженныеСведения = Ложь;
	
	СведенияОЗагрузкеСубъектовРФ = АдресныйКлассификаторСлужебный.СведенияОЗагрузкеСубъектовРФ();
	Для каждого СведенияОбСубъектеРФ Из СведенияОЗагрузкеСубъектовРФ Цикл
		
		ЗагруженныеСведенияРегионаАктуальны = СведенияОбСубъектеРФ.Загружено;
		
		Если КлассификаторДоступен И СведенияОбСубъектеРФ.Устарело = Истина Тогда
			ЗагруженныеСведенияРегионаАктуальны = Ложь;
		КонецЕсли;
		
		Если СведенияОбСубъектеРФ.Загружено Тогда
			ЕстьЗагруженныеСведения = Истина;
		КонецЕсли;
		
		Если ЗагруженныеСведенияРегионаАктуальны Тогда
			ИспользоватьЗагруженные = Истина;
		КонецЕсли;
		
		Сведения = Новый Структура();
		Сведения.Вставить("ИспользоватьЗагруженные", ЗагруженныеСведенияРегионаАктуальны);
		Сведения.Вставить("ДатаЗагрузки", СведенияОбСубъектеРФ.ДатаЗагрузки);
		Результат.Вставить(СведенияОбСубъектеРФ.КодСубъектаРФ, Сведения);
		
	КонецЦикла;
	
	Результат.Вставить("ИспользоватьЗагруженные", ИспользоватьЗагруженные);
	Результат.Вставить("ЕстьЗагруженныеСведения", ЕстьЗагруженныеСведения);
	
	Возврат Новый ФиксированноеСоответствие(Результат);
	
КонецФункции

// Возвращает является ли источником данных веб сервис.
//
// Возвращаемое значение:
//     Булево - если веб сервис является источником адресных сведений, то возвращает Истина.
//
Функция ИсточникДанныхАдресногоКлассификатораВебСервис() Экспорт
	
	СервисРезультат = АдресныйКлассификаторСлужебный.ВерсияПоставщикаДанных();
	Возврат СервисРезультат.Данные = Истина;
	
КонецФункции

Функция СокращенияНаименованийДомов() Экспорт
	
	Результат = Новый Соответствие;
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	СлужебныеАдресныеСведения.Тип КАК Тип,
	|	СлужебныеАдресныеСведения.Ключ КАК Ключ,
	|	СлужебныеАдресныеСведения.Значение КАК Значение
	|ИЗ
	|	РегистрСведений.СлужебныеАдресныеСведения КАК СлужебныеАдресныеСведения
	|ГДЕ
	|	СлужебныеАдресныеСведения.Тип = ""ТипыВладений""
	|	ИЛИ СлужебныеАдресныеСведения.Тип = ""ТипыСтроений""
	|
	|УПОРЯДОЧИТЬ ПО
	|	Значение";
	
	РезультатЗапроса = Запрос.Выполнить().Выбрать();
	
	Пока РезультатЗапроса.Следующий() Цикл
			Результат.Вставить(ВРег(РезультатЗапроса.Ключ), РезультатЗапроса.Значение);
	КонецЦикла;
	
	Возврат Новый ФиксированноеСоответствие(Результат);
	
КонецФункции

Функция СокращенияНаименованийПомещений() Экспорт
	
	Результат = Новый Соответствие;
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	СлужебныеАдресныеСведения.Тип КАК Тип,
	|	СлужебныеАдресныеСведения.Ключ КАК Ключ,
	|	СлужебныеАдресныеСведения.Значение КАК Значение
	|ИЗ
	|	РегистрСведений.СлужебныеАдресныеСведения КАК СлужебныеАдресныеСведения
	|ГДЕ
	|	СлужебныеАдресныеСведения.Тип = ""ТипыПомещений""
	|
	|УПОРЯДОЧИТЬ ПО
	|	Значение";
	
	РезультатЗапроса = Запрос.Выполнить().Выбрать();
	
	Пока РезультатЗапроса.Следующий() Цикл
			Результат.Вставить(ВРег(РезультатЗапроса.Ключ), РезультатЗапроса.Значение);
	КонецЦикла;
	
	Возврат Новый ФиксированноеСоответствие(Результат);
	
КонецФункции

// Параметры:
//  Наименование - Строка - наименование региона
//  ТипОбъекта - Строка - тип региона
// 
// Возвращаемое значение:
//  ФиксированнаяСтруктура:
//    * Загружен - Булево
//    * Устарел - Булево
//    * КодСубъектаРФ - Число
//    * ПолноеНаименование - Строка
//
Функция СведенияОРегионе(Знач Наименование, ТипОбъекта = "") Экспорт
	
	Результат = АдресныйКлассификаторСлужебный.СведенияОЗагруженномРегионе();
	
	Если ПустаяСтрока(ТипОбъекта) Тогда
		НаименованиеИТипОбъекта = АдресныйКлассификаторСлужебный.НаименованиеИТипОбъекта(Наименование, Истина);

		Наименование = НаименованиеИТипОбъекта.Наименование;
		ТипОбъекта = НаименованиеИТипОбъекта.ТипОбъекта;
	КонецЕсли;
	
	РезультатЗапроса = АдресныйКлассификаторСлужебный.АктуальныеДанныеОРегионе(Наименование, ТипОбъекта);
	
	Если РезультатЗапроса.Пустой() Тогда
		
		АдресныйКлассификаторСлужебный.ВыполнитьНачальноеЗаполнение();
		РезультатЗапроса = АдресныйКлассификаторСлужебный.АктуальныеДанныеОРегионе(Наименование, ТипОбъекта);
		
		Если РезультатЗапроса.Пустой() Тогда
			
			КодСубъектаРФ = СписокРегионов().Получить(ВРег(Наименование));
			Если КодСубъектаРФ <> Неопределено Тогда 
				Результат.КодСубъектаРФ = КодСубъектаРФ;
			ИначеЕсли СтрСравнить(Наименование, 
				АдресныйКлассификаторСлужебный.ДействующиеНаименованиеКемеровскойОбласти()) = 0 Тогда
					Результат.КодСубъектаРФ = 42;
			Иначе
				АдресныйКлассификаторСлужебный.ПроверкаНаУстаревшийРегион(Результат, Наименование, ТипОбъекта);
			КонецЕсли;
			
			Возврат Новый ФиксированнаяСтруктура(Результат);
			
		КонецЕсли;
	КонецЕсли;
	
	ИнформацияОРегионе = РезультатЗапроса.Выбрать();
	
	Если ИнформацияОРегионе.Следующий() Тогда
		Результат.Загружен = ИнформацияОРегионе.РегионЗагружен;
		Результат.КодСубъектаРФ = ИнформацияОРегионе.КодСубъектаРФ;
		Результат.ПолноеНаименование = АдресныйКлассификаторСлужебный.ПолноеНаименованиеРегионаПоКоду(Результат.КодСубъектаРФ);
	КонецЕсли;
	
	Возврат Новый ФиксированнаяСтруктура(Результат);

КонецФункции

// Возвращаемое значение:
//  ФиксированноеСоответствие из КлючИЗначение:
//   * Ключ - Число
//   * Значение - Строка
//
Функция ПолныеНаименованияРегионов() Экспорт
	
	Результат = Новый Соответствие();
	
	Запрос = Новый Запрос;
	Запрос.Текст =
	"ВЫБРАТЬ
	|	АдресныеОбъекты.КодСубъектаРФ КАК КодСубъектаРФ,
	|	АдресныеОбъекты.Наименование + "" "" + АдресныеОбъекты.ТипОбъекта КАК Наименование
	|ПОМЕСТИТЬ АдресныеОбъекты
	|ИЗ
	|	РегистрСведений.АдресныеОбъекты КАК АдресныеОбъекты
	|ГДЕ
	|	АдресныеОбъекты.Уровень = 1
	|
	|ИНДЕКСИРОВАТЬ ПО
	|	КодСубъектаРФ
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ЕСТЬNULL(ВЫРАЗИТЬ(СлужебныеАдресныеСведения.Идентификатор КАК ЧИСЛО(2, 0)), АдресныеОбъекты.КодСубъектаРФ) КАК КодСубъектаРФ,
	|	СлужебныеАдресныеСведения.Значение КАК ПолноеНаименование,
	|	АдресныеОбъекты.Наименование КАК Наименование
	|ИЗ
	|	АдресныеОбъекты КАК АдресныеОбъекты
	|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.СлужебныеАдресныеСведения КАК СлужебныеАдресныеСведения
	|		ПО ((ВЫРАЗИТЬ(СлужебныеАдресныеСведения.Идентификатор КАК ЧИСЛО(2, 0))) = АдресныеОбъекты.КодСубъектаРФ)
	|			И (СлужебныеАдресныеСведения.Тип = &Тип)";
			
	Запрос.УстановитьПараметр("Тип", "СубъектыРФ");
	
	Выборка = Запрос.Выполнить().Выбрать();
	
	Классификатор = РегистрыСведений.АдресныеОбъекты.КлассификаторСубъектовРФ();
	
	Пока Выборка.Следующий() Цикл
		
		РегионИзКлассификатора = Классификатор.Найти(Выборка.КодСубъектаРФ, "КодСубъектаРФ");
		
		Если ЗначениеЗаполнено(Выборка.ПолноеНаименование) Тогда
			Результат.Вставить(Выборка.КодСубъектаРФ, Выборка.ПолноеНаименование);
		Иначе
			
			Если РегионИзКлассификатора <> Неопределено Тогда
				Результат.Вставить(РегионИзКлассификатора.КодСубъектаРФ, РегионИзКлассификатора.ПолноеНаименование);
			Иначе
				Результат.Вставить(Выборка.КодСубъектаРФ, Выборка.Наименование);
			КонецЕсли; 
		КонецЕсли;
		
		Если РегионИзКлассификатора <> Неопределено Тогда
			Классификатор.Удалить(РегионИзКлассификатора);
		КонецЕсли;
		
	КонецЦикла;
	
	Для Каждого РегионИзКлассификатора Из Классификатор Цикл
		Результат.Вставить(РегионИзКлассификатора.КодСубъектаРФ, РегионИзКлассификатора.ПолноеНаименование);
	КонецЦикла;

	Возврат Новый ФиксированноеСоответствие(Результат);
	
КонецФункции

Функция СписокРегионов() Экспорт
	
	Классификатор = РегистрыСведений.АдресныеОбъекты.КлассификаторСубъектовРФ();
	
	Результат = Новый Соответствие;
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	АдресныеОбъекты.КодСубъектаРФ КАК КодСубъектаРФ,
	|	АдресныеОбъекты.Наименование КАК Наименование,
	|	АдресныеОбъекты.Наименование + "" "" + АдресныеОбъекты.ТипОбъекта КАК ПолноеНаименование
	|ИЗ
	|	РегистрСведений.АдресныеОбъекты КАК АдресныеОбъекты
	|ГДЕ
	|	АдресныеОбъекты.Уровень = 1";
	
	РезультатЗапроса = Запрос.Выполнить();
	
	ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
	
	ПолныеНаименованияРегионов = ПолныеНаименованияРегионов();
	
	Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
		
		Результат.Вставить(ВРег(ВыборкаДетальныеЗаписи.Наименование), ВыборкаДетальныеЗаписи.КодСубъектаРФ);
		Результат.Вставить(ВРег(ВыборкаДетальныеЗаписи.ПолноеНаименование), ВыборкаДетальныеЗаписи.КодСубъектаРФ);
		
		ПолныеНаименованияРегиона = ПолныеНаименованияРегионов.Получить(ВыборкаДетальныеЗаписи.КодСубъектаРФ);
		
		Если ЗначениеЗаполнено(ПолныеНаименованияРегиона) Тогда
			Результат.Вставить(ВРег(ПолныеНаименованияРегиона), ВыборкаДетальныеЗаписи.КодСубъектаРФ);
		КонецЕсли;
		
	КонецЦикла;
	
	Возврат Новый ФиксированноеСоответствие(Результат);
	
КонецФункции

Функция ИдентификаторыГородовФедеральногоЗначения() Экспорт
	
	Результат = Новый Соответствие;
	
	КодыСубъектовРФ = Новый Массив;
	КодыСубъектовРФ.Добавить(77);
	КодыСубъектовРФ.Добавить(78);
	КодыСубъектовРФ.Добавить(92);
	КодыСубъектовРФ.Добавить(99);
	
	Запрос = Новый Запрос;
	Запрос.Текст =
	"ВЫБРАТЬ
	|	АдресныеОбъекты.Идентификатор КАК Идентификатор
	|ИЗ
	|	РегистрСведений.АдресныеОбъекты КАК АдресныеОбъекты
	|ГДЕ
	|	АдресныеОбъекты.КодСубъектаРФ В (&КодыСубъектовРФ)
	|	И АдресныеОбъекты.Уровень = 1";
	
	Запрос.УстановитьПараметр("КодыСубъектовРФ", КодыСубъектовРФ);
	
	ВыборкаДетальныеЗаписи = Запрос.Выполнить().Выбрать();

	Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
		Результат.Вставить(ВыборкаДетальныеЗаписи.Идентификатор, Истина);
	КонецЦикла;
	
	Возврат Новый ФиксированноеСоответствие(Результат);
	
КонецФункции

Функция СписокСокращений() Экспорт
	
	Результат = Новый Соответствие;
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	УровниСокращенийАдресныхСведений.Сокращение КАК Сокращение,
	|	УровниСокращенийАдресныхСведений.Уровень КАК Уровень,
	|	УровниСокращенийАдресныхСведений.Значение КАК Значение
	|ИЗ
	|	РегистрСведений.УровниСокращенийАдресныхСведений КАК УровниСокращенийАдресныхСведений";
	
	РезультатЗапроса = Запрос.Выполнить();
	
	Если Не РезультатЗапроса.Пустой() Тогда
		ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
		
		Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
			Результат.Вставить(Строка(ВыборкаДетальныеЗаписи.Уровень) + ВРег(ВыборкаДетальныеЗаписи.Сокращение), 
				ВыборкаДетальныеЗаписи.Значение);
		КонецЦикла;
		
	Иначе
		
		АдресныеСокращения = РегистрыСведений.АдресныеОбъекты.АдресныеСокращения();
		Для Каждого ЭлементСокращение Из АдресныеСокращения Цикл
			Результат.Вставить(Строка(ЭлементСокращение.Уровень) + ВРег(ЭлементСокращение.Сокращение),
				ЭлементСокращение.Наименование);
		КонецЦикла;
		
	КонецЕсли;
	
	Возврат Новый ФиксированноеСоответствие(Результат);
	
КонецФункции

Функция АдресныеСокращенияПриказМинфинаРФ171н() Экспорт
	
	АдресныеСокращения = РегистрыСведений.АдресныеОбъекты.АдресныеСокращения();
	
	Результат = Новый Соответствие;
	
	Для каждого ЭлементИзПеречня Из АдресныеСокращения Цикл
		Результат.Вставить(ВРег(ЭлементИзПеречня.Наименование), ЭлементИзПеречня.СокращениеПриказаМинфинаРФ171н);
	КонецЦикла;
	
	Возврат Новый ФиксированноеСоответствие(Результат);
	
КонецФункции

Функция НомераУровнейАдресаПоНаименованию() Экспорт
	
	Уровни = Новый Структура;
	
	Уровни.Вставить("area", 1);
	Уровни.Вставить("district", 2);
	Уровни.Вставить("munDistrict", 3);
	Уровни.Вставить("settlement", 4);
	Уровни.Вставить("city", 5);
	Уровни.Вставить("locality", 6);
	Уровни.Вставить("territory", 7);
	Уровни.Вставить("street", 8);
	
	Возврат Новый ФиксированнаяСтруктура(Уровни);
	
КонецФункции

Функция МуниципальныеРайоны() Экспорт
	
	// АПК: 1297-выкл Данные адресного классификатора, не локализуются
	Результат = Новый Соответствие;
	Результат.Вставить("Г.О.", "Городской округ"); // @Non-NLS-1, @Non-NLS-2
	Результат.Вставить("М.Р-Н", "муниципальный район"); // @Non-NLS-1, @Non-NLS-2
	Результат.Вставить("ВН.ТЕР.", "Внутригородская территория"); // @Non-NLS-1, @Non-NLS-2
	Результат.Вставить("ВН.ТЕР.Г.", "Внутригородская территория"); // @Non-NLS-1, @Non-NLS-2
	Результат.Вставить("М.О.", "Муниципальный округ"); // @Non-NLS-1, @Non-NLS-2
	Результат.Вставить("МУН. ОКР.", "Муниципальный округ"); // @Non-NLS-1, @Non-NLS-2
	// АПК: 1297-вкл
	
	Возврат Новый ФиксированноеСоответствие(Результат);
	
КонецФункции

Функция Поселения() Экспорт
	
	// АПК: 1297-выкл Данные адресного классификатора, не локализуются
	Результат = Новый Соответствие;
	Результат.Вставить("Г.П.", "Городское поселение"); // @Non-NLS-1, @Non-NLS-2
	Результат.Вставить("Г. П.", "Городское поселение"); // @Non-NLS-1, @Non-NLS-2
	Результат.Вставить("ВН.Р-Н", "Внутригородской район"); // @Non-NLS-1, @Non-NLS-2
	Результат.Вставить("С.П.", "Сельское поселение"); // @Non-NLS-1, @Non-NLS-2
	Результат.Вставить("МЕЖ.ТЕР.", "Межселенная территория"); // @Non-NLS-1, @Non-NLS-2
	// АПК: 1297-вкл
	
	
	Возврат Новый ФиксированноеСоответствие(Результат);
	
КонецФункции

#КонецОбласти