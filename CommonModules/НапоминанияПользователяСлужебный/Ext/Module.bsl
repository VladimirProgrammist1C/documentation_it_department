﻿///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2021, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область СлужебныйПрограммныйИнтерфейс

////////////////////////////////////////////////////////////////////////////////
// Обработчики событий подсистем конфигурации.

// См. ОбщегоНазначенияПереопределяемый.ПриДобавленииПараметровРаботыКлиентаПриЗапуске.
Процедура ПриДобавленииПараметровРаботыКлиентаПриЗапуске(Параметры) Экспорт
	
	Параметры.Вставить("НастройкиНапоминаний", 
		Новый ФиксированнаяСтруктура("ИспользоватьНапоминания", ПолучитьНастройкиНапоминаний().ИспользоватьНапоминания));
		
КонецПроцедуры 

// См. ОбщегоНазначенияПереопределяемый.ПриДобавленииПараметровРаботыКлиента.
Процедура ПриДобавленииПараметровРаботыКлиента(Параметры) Экспорт
	
	Параметры.Вставить("НастройкиНапоминаний", 
		Новый ФиксированнаяСтруктура(ПолучитьНастройкиНапоминаний()));
	
КонецПроцедуры

// См. ОбщегоНазначенияПереопределяемый.ПриДобавленииПереименованийОбъектовМетаданных.
Процедура ПриДобавленииПереименованийОбъектовМетаданных(Итог) Экспорт
	
	Библиотека = "СтандартныеПодсистемы";
	
	СтароеИмя = "Роль.ИспользованиеНапоминаний";
	НовоеИмя  = "Роль.ДобавлениеИзменениеНапоминаний";
	ОбщегоНазначения.ДобавитьПереименование(Итог, "2.3.3.11", СтароеИмя, НовоеИмя, Библиотека);
	
КонецПроцедуры

// См. УправлениеДоступомПереопределяемый.ПриЗаполненииСписковСОграничениемДоступа.
Процедура ПриЗаполненииСписковСОграничениемДоступа(Списки) Экспорт
	
	Списки.Вставить(Метаданные.РегистрыСведений.НапоминанияПользователя, Истина);
	
КонецПроцедуры

// Изменить текст напоминаний по предмету.
// 
// Параметры:
//  Предмет - ЛюбаяСсылка - предмет напоминания;
//  Идентификатор - Строка - уточняет предмет напоминания, например, "ДеньРождения".
//  НовыйТекст - Строка - текст напоминания;
//
Процедура ИзменитьТекстНапоминанийПоПредмету(Предмет, Идентификатор, НовыйТекст) Экспорт
	
	Запрос = Новый Запрос;
	Запрос.Текст =
		"ВЫБРАТЬ
		|	НапоминанияПользователя.Пользователь,
		|	НапоминанияПользователя.ВремяСобытия,
		|	НапоминанияПользователя.Источник
		|ИЗ
		|	РегистрСведений.НапоминанияПользователя КАК НапоминанияПользователя
		|ГДЕ
		|	НапоминанияПользователя.Идентификатор = &Идентификатор
		|	И НапоминанияПользователя.Источник = &Источник";
	
	Запрос.УстановитьПараметр("Идентификатор", Идентификатор);
	Запрос.УстановитьПараметр("Источник", Предмет);
	
	РезультатЗапроса = Запрос.Выполнить();
	ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
	Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
		МенеджерЗаписи = РегистрыСведений.НапоминанияПользователя.СоздатьМенеджерЗаписи();
		ЗаполнитьЗначенияСвойств(МенеджерЗаписи, ВыборкаДетальныеЗаписи);
		МенеджерЗаписи.Прочитать();
		МенеджерЗаписи.Описание = НовыйТекст;
		МенеджерЗаписи.Записать();
	КонецЦикла;
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

Функция НастройкиПодсистемы() Экспорт
	Настройки = Новый Структура;
	Настройки.Вставить("Расписания", ПолучитьСтандартныеРасписанияДляНапоминания());
	Настройки.Вставить("СтандартныеИнтервалы", СтандартныеИнтервалыОповещения());
	НапоминанияПользователяПереопределяемый.ПриОпределенииНастроек(Настройки);
	
	Возврат Настройки;
КонецФункции

Функция СтандартныеИнтервалыОповещения()
	
	Результат = Новый Массив;
	Результат.Добавить(НСтр("ru = '5 минут'"));
	Результат.Добавить(НСтр("ru = '10 минут'"));
	Результат.Добавить(НСтр("ru = '15 минут'"));
	Результат.Добавить(НСтр("ru = '30 минут'"));
	Результат.Добавить(НСтр("ru = '1 час'"));
	Результат.Добавить(НСтр("ru = '2 часа'"));
	Результат.Добавить(НСтр("ru = '4 часа'"));
	Результат.Добавить(НСтр("ru = '8 часов'"));
	Результат.Добавить(НСтр("ru = '1 день'"));
	Результат.Добавить(НСтр("ru = '2 дня'"));
	Результат.Добавить(НСтр("ru = '3 дня'"));
	Результат.Добавить(НСтр("ru = '1 неделю'"));
	Результат.Добавить(НСтр("ru = '2 недели'"));
	
	Возврат Результат;
	
КонецФункции

// Возвращает стандартные расписания для периодических напоминаний.
Функция ПолучитьСтандартныеРасписанияДляНапоминания()
	
	Результат = Новый Соответствие;
		
	// по понедельникам в 9:00
	Расписание = Новый РасписаниеРегламентногоЗадания;
	Расписание.ПериодПовтораДней = 1;
	Расписание.ПериодНедель = 1;
	Расписание.ВремяНачала = '00010101090000';
	ДниНедели = Новый Массив;
	ДниНедели.Добавить(1);
	Расписание.ДниНедели = ДниНедели;
	Результат.Вставить(НСтр("ru = 'по понедельникам, в 9:00'"), Расписание);
	
	// по пятницам в 15:00
	Расписание = Новый РасписаниеРегламентногоЗадания;
	Расписание.ПериодПовтораДней = 1;
	Расписание.ПериодНедель = 1;
	Расписание.ВремяНачала = '00010101150000';
	ДниНедели = Новый Массив;
	ДниНедели.Добавить(5);
	Расписание.ДниНедели = ДниНедели;
	Результат.Вставить(НСтр("ru = 'по пятницам, в 15:00'"), Расписание);
	
	// каждый день в 9:00
	Расписание = Новый РасписаниеРегламентногоЗадания;
	Расписание.ПериодПовтораДней = 1;
	Расписание.ПериодНедель = 1;
	Расписание.ВремяНачала = '00010101090000';
	Результат.Вставить(НСтр("ru = 'каждый день, в 9:00'"), Расписание);
	
	Возврат Результат;
	
КонецФункции

// Возвращает структуру настроек напоминаний пользователя.
Функция ПолучитьНастройкиНапоминаний()
	
	Результат = Новый Структура;
	Результат.Вставить("ИспользоватьНапоминания", ЕстьПравоИспользованияНапоминаний() И ПолучитьФункциональнуюОпцию("ИспользоватьНапоминанияПользователя"));
	Результат.Вставить("ИнтервалПроверкиНапоминаний", ПолучитьИнтервалПроверкиНапоминаний());
	
	Возврат Результат;
	
КонецФункции

// Проверяет наличие права изменения РС НапоминанияПользователя.
//
// Возвращаемое значение:
//  Булево - Истина, если право есть.
//
Функция ЕстьПравоИспользованияНапоминаний()
	Возврат ПравоДоступа("Изменение", Метаданные.РегистрыСведений.НапоминанияПользователя); 
КонецФункции

// Возвращает ближайшую дату по расписанию относительно даты, переданной в параметре.
//
// Параметры:
//  Расписание - РасписаниеРегламентногоЗадания - любое расписание.
//  ПредыдущаяДата - Дата - дата предыдущего события по расписанию.
//  ИскатьТолькоБудущиеДаты - Булево - Ложь, если требуется найти дату в прошлом.
//  
// Возвращаемое значение:
//   Дата - дата и время следующего события по расписанию.
//
Функция ПолучитьБлижайшуюДатуСобытияПоРасписанию(Расписание, ПредыдущаяДата = '000101010000', ИскатьТолькоБудущиеДаты = Истина) Экспорт

	Результат = Неопределено;
	ТекущаяДатаСеанса = ТекущаяДатаСеанса();
	
	ДатаОтсчета = ПредыдущаяДата;
	Если Не ЗначениеЗаполнено(ДатаОтсчета) Тогда
		ДатаОтсчета = ТекущаяДатаСеанса;
	КонецЕсли;
	Если ИскатьТолькоБудущиеДаты Тогда
		ДатаОтсчета = Макс(ДатаОтсчета, ТекущаяДатаСеанса);
	КонецЕсли;
	
	Календарь = ПолучитьКалендарьНаБудущее(365*4+1, ДатаОтсчета, Расписание.ДатаНачала, Расписание.ПериодПовтораДней, Расписание.ПериодНедель);
	
	ДниНедели = Расписание.ДниНедели;
	Если ДниНедели.Количество() = 0 Тогда
		ДниНедели = Новый Массив;
		Для День = 1 По 7 Цикл
			ДниНедели.Добавить(День);
		КонецЦикла;
	КонецЕсли;
	
	Месяцы = Расписание.Месяцы;
	Если Месяцы.Количество() = 0 Тогда
		Месяцы = Новый Массив;
		Для Месяц = 1 По 12 Цикл
			Месяцы.Добавить(Месяц);
		КонецЦикла;
	КонецЕсли;
	
	Запрос = Новый Запрос;
	Запрос.МенеджерВременныхТаблиц = Новый МенеджерВременныхТаблиц;
	
	Запрос.Текст = "ВЫБРАТЬ * ПОМЕСТИТЬ Календарь ИЗ &Календарь КАК Календарь";
	Запрос.УстановитьПараметр("Календарь", Календарь);
	Запрос.Выполнить();
	
	Запрос.УстановитьПараметр("ДатаНачала",			Расписание.ДатаНачала);
	Запрос.УстановитьПараметр("ДатаКонца",			Расписание.ДатаКонца);
	Запрос.УстановитьПараметр("ДниНедели",			ДниНедели);
	Запрос.УстановитьПараметр("Месяцы",				Месяцы);
	Запрос.УстановитьПараметр("ДеньВМесяце",		Расписание.ДеньВМесяце);
	Запрос.УстановитьПараметр("ДеньНеделиВМесяце",	Расписание.ДеньНеделиВМесяце);
	Запрос.УстановитьПараметр("ПериодПовтораДней",	?(Расписание.ПериодПовтораДней = 0,1,Расписание.ПериодПовтораДней));
	Запрос.УстановитьПараметр("ПериодНедель",		?(Расписание.ПериодНедель = 0,1,Расписание.ПериодНедель));
	
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	Календарь.Дата,
	|	Календарь.НомерМесяца,
	|	Календарь.НомерДняНеделиВМесяце,
	|	Календарь.НомерДняНеделиСКонцаМесяца,
	|	Календарь.НомерДняВМесяце,
	|	Календарь.НомерДняВМесяцеСКонцаМесяца,
	|	Календарь.НомерДняВНеделе,
	|	Календарь.НомерДняВПериоде,
	|	Календарь.НомерНеделиВПериоде
	|ИЗ
	|	Календарь КАК Календарь
	|ГДЕ
	|	ВЫБОР
	|			КОГДА &ДатаНачала = ДАТАВРЕМЯ(1, 1, 1, 0, 0, 0)
	|				ТОГДА ИСТИНА
	|			ИНАЧЕ Календарь.Дата >= &ДатаНачала
	|		КОНЕЦ
	|	И ВЫБОР
	|			КОГДА &ДатаКонца = ДАТАВРЕМЯ(1, 1, 1, 0, 0, 0)
	|				ТОГДА ИСТИНА
	|			ИНАЧЕ Календарь.Дата <= &ДатаКонца
	|		КОНЕЦ
	|	И Календарь.НомерДняВНеделе В(&ДниНедели)
	|	И Календарь.НомерМесяца В(&Месяцы)
	|	И ВЫБОР
	|			КОГДА &ДеньВМесяце = 0
	|				ТОГДА ИСТИНА
	|			ИНАЧЕ ВЫБОР
	|					КОГДА &ДеньВМесяце > 0
	|						ТОГДА Календарь.НомерДняВМесяце = &ДеньВМесяце
	|					ИНАЧЕ Календарь.НомерДняВМесяцеСКонцаМесяца = -&ДеньВМесяце
	|				КОНЕЦ
	|		КОНЕЦ
	|	И ВЫБОР
	|			КОГДА &ДеньНеделиВМесяце = 0
	|				ТОГДА ИСТИНА
	|			ИНАЧЕ ВЫБОР
	|					КОГДА &ДеньНеделиВМесяце > 0
	|						ТОГДА Календарь.НомерДняНеделиВМесяце = &ДеньНеделиВМесяце
	|					ИНАЧЕ Календарь.НомерДняНеделиСКонцаМесяца = -&ДеньНеделиВМесяце
	|				КОНЕЦ
	|		КОНЕЦ
	|	И Календарь.НомерДняВПериоде = &ПериодПовтораДней
	|	И Календарь.НомерНеделиВПериоде = &ПериодНедель";
	
	Выборка = Запрос.Выполнить().Выбрать();
	
	Если Выборка.Следующий() Тогда
		БлижайшаяДата = Выборка.Дата;
		ВремяОтсчета = '00010101';
		Если НачалоДня(БлижайшаяДата) = НачалоДня(ДатаОтсчета) Тогда
			ВремяОтсчета = ВремяОтсчета + (ДатаОтсчета-НачалоДня(ДатаОтсчета));
		КонецЕсли;
		
		БлижайшееВремя = ПолучитьБлижайшееВремяИзРасписания(Расписание, ВремяОтсчета);
		Если БлижайшееВремя <> Неопределено Тогда
			Результат = БлижайшаяДата + (БлижайшееВремя - '00010101');
		Иначе
			Если Выборка.Следующий() Тогда
				Время = ПолучитьБлижайшееВремяИзРасписания(Расписание);
				Результат = Выборка.Дата + (Время - '00010101');
			КонецЕсли;
		КонецЕсли;
	КонецЕсли;
	
	Возврат Результат;
	
КонецФункции

Функция ПолучитьКалендарьНаБудущее(КоличествоДнейКалендаря, ДатаОтсчета, Знач ДатаНачалаПериодичности = Неопределено, Знач ПериодДней = 1, Знач ПериодНедель = 1) 
	
	Если ПериодНедель = 0 Тогда 
		ПериодНедель = 1;
	КонецЕсли;
	
	Если ПериодДней = 0 Тогда
		ПериодДней = 1;
	КонецЕсли;
	
	Если Не ЗначениеЗаполнено(ДатаНачалаПериодичности) Тогда
		ДатаНачалаПериодичности = ДатаОтсчета;
	КонецЕсли;
	
	Календарь = Новый ТаблицаЗначений;
	Календарь.Колонки.Добавить("Дата", Новый ОписаниеТипов("Дата",,,Новый КвалификаторыДаты()));
	Календарь.Колонки.Добавить("НомерМесяца", Новый ОписаниеТипов("Число",Новый КвалификаторыЧисла(2,0,ДопустимыйЗнак.Неотрицательный)));
	Календарь.Колонки.Добавить("НомерДняНеделиВМесяце", Новый ОписаниеТипов("Число",Новый КвалификаторыЧисла(1,0,ДопустимыйЗнак.Неотрицательный)));
	Календарь.Колонки.Добавить("НомерДняНеделиСКонцаМесяца", Новый ОписаниеТипов("Число",Новый КвалификаторыЧисла(1,0,ДопустимыйЗнак.Неотрицательный)));
	Календарь.Колонки.Добавить("НомерДняВМесяце", Новый ОписаниеТипов("Число",Новый КвалификаторыЧисла(2,0,ДопустимыйЗнак.Неотрицательный)));
	Календарь.Колонки.Добавить("НомерДняВМесяцеСКонцаМесяца", Новый ОписаниеТипов("Число",Новый КвалификаторыЧисла(2,0,ДопустимыйЗнак.Неотрицательный)));
	Календарь.Колонки.Добавить("НомерДняВНеделе", Новый ОписаниеТипов("Число",Новый КвалификаторыЧисла(2,0,ДопустимыйЗнак.Неотрицательный)));	
	Календарь.Колонки.Добавить("НомерДняВПериоде", Новый ОписаниеТипов("Число",Новый КвалификаторыЧисла(3,0,ДопустимыйЗнак.Неотрицательный)));	
	Календарь.Колонки.Добавить("НомерНеделиВПериоде", Новый ОписаниеТипов("Число",Новый КвалификаторыЧисла(3,0,ДопустимыйЗнак.Неотрицательный)));
	
	Дата = НачалоДня(ДатаОтсчета);
	ДатаНачалаПериодичности = НачалоДня(ДатаНачалаПериодичности);
	НомерДняВПериоде = 0;
	НомерНеделиВПериоде = 0;
	
	Если ДатаНачалаПериодичности <= Дата Тогда
		КоличествоДней = (Дата - ДатаНачалаПериодичности)/60/60/24;
		НомерДняВПериоде = КоличествоДней - Цел(КоличествоДней/ПериодДней)*ПериодДней;
		
		КоличествоНедель = Цел(КоличествоДней / 7);
		НомерНеделиВПериоде = КоличествоНедель - Цел(КоличествоНедель/ПериодНедель)*ПериодНедель;
	КонецЕсли;
	
	Если НомерДняВПериоде = 0 Тогда 
		НомерДняВПериоде = ПериодДней;
	КонецЕсли;
	
	Если НомерНеделиВПериоде = 0 Тогда 
		НомерНеделиВПериоде = ПериодНедель;
	КонецЕсли;
	
	Для Счетчик = 0 По КоличествоДнейКалендаря - 1 Цикл
		
		Дата = НачалоДня(ДатаОтсчета) + Счетчик * 60*60*24;
		НоваяСтрока = Календарь.Добавить();
		НоваяСтрока.Дата = Дата;
		НоваяСтрока.НомерМесяца = Месяц(Дата);
		НоваяСтрока.НомерДняНеделиВМесяце = Цел((Дата - НачалоМесяца(Дата))/60/60/24/7) + 1;
		НоваяСтрока.НомерДняНеделиСКонцаМесяца = Цел((КонецМесяца(НачалоДня(Дата)) - Дата)/60/60/24/7) + 1;
		НоваяСтрока.НомерДняВМесяце = День(Дата);
		НоваяСтрока.НомерДняВМесяцеСКонцаМесяца = День(КонецМесяца(НачалоДня(Дата))) - День(Дата) + 1;
		НоваяСтрока.НомерДняВНеделе = ДеньНедели(Дата);
		
		Если ДатаНачалаПериодичности <= Дата Тогда
			НоваяСтрока.НомерДняВПериоде = НомерДняВПериоде;
			НоваяСтрока.НомерНеделиВПериоде = НомерНеделиВПериоде;
			
			НомерДняВПериоде = ?(НомерДняВПериоде+1 > ПериодДней, 1, НомерДняВПериоде+1);
			
			Если НоваяСтрока.НомерДняВНеделе = 1 Тогда
				НомерНеделиВПериоде = ?(НомерНеделиВПериоде+1 > ПериодНедель, 1, НомерНеделиВПериоде+1);
			КонецЕсли;
		КонецЕсли;
		
	КонецЦикла;
	
	Возврат Календарь;
	
КонецФункции

Функция ПолучитьБлижайшееВремяИзРасписания(Расписание, Знач ВремяОтсчета = '000101010000')
	
	Результат = Неопределено;
	
	СписокЗначений = Новый СписокЗначений;
	
	Если Расписание.ДетальныеРасписанияДня.Количество() = 0 Тогда
		СписокЗначений.Добавить(Расписание.ВремяНачала);
	Иначе
		Для Каждого РасписаниеДня Из Расписание.ДетальныеРасписанияДня Цикл
			СписокЗначений.Добавить(РасписаниеДня.ВремяНачала);
		КонецЦикла;
	КонецЕсли;
	
	СписокЗначений.СортироватьПоЗначению(НаправлениеСортировки.Возр);
	
	Для Каждого ВремяДня Из СписокЗначений Цикл
		Если ВремяОтсчета <= ВремяДня.Значение Тогда
			Результат = ВремяДня.Значение;
			Прервать;
		КонецЕсли;
	КонецЦикла;
	
	Возврат Результат;
	
КонецФункции

// Параметры:
//  Расписание - РасписаниеРегламентногоЗадания
//  НачалоПериода - Дата
//  КонецПериода - Дата
// Возвращаемое значение:
//  Массив из Дата
// 
Функция ГрафикСобытия(Расписание, НачалоПериода, КонецПериода)

	Результат = Неопределено;
	
	ДатаОтсчета = НачалоПериода;
	
	Календарь = ПолучитьКалендарьНаБудущее((НачалоДня(КонецПериода) - НачалоДня(НачалоПериода)) / (60*60*24) + 1, 
		ДатаОтсчета, Расписание.ДатаНачала, Расписание.ПериодПовтораДней, Расписание.ПериодНедель);
	
	ДниНедели = Расписание.ДниНедели;
	Если ДниНедели.Количество() = 0 Тогда
		ДниНедели = Новый Массив;
		Для День = 1 По 7 Цикл
			ДниНедели.Добавить(День);
		КонецЦикла;
	КонецЕсли;
	
	Месяцы = Расписание.Месяцы;
	Если Месяцы.Количество() = 0 Тогда
		Месяцы = Новый Массив;
		Для Месяц = 1 По 12 Цикл
			Месяцы.Добавить(Месяц);
		КонецЦикла;
	КонецЕсли;
	
	Запрос = Новый Запрос;
	Запрос.МенеджерВременныхТаблиц = Новый МенеджерВременныхТаблиц;
	
	Запрос.Текст = "ВЫБРАТЬ * ПОМЕСТИТЬ Календарь ИЗ &Календарь КАК Календарь";
	Запрос.УстановитьПараметр("Календарь", Календарь);
	Запрос.Выполнить();
	
	Запрос.УстановитьПараметр("ДатаНачала",			Расписание.ДатаНачала);
	Запрос.УстановитьПараметр("ДатаКонца",			Расписание.ДатаКонца);
	Запрос.УстановитьПараметр("ДниНедели",			ДниНедели);
	Запрос.УстановитьПараметр("Месяцы",				Месяцы);
	Запрос.УстановитьПараметр("ДеньВМесяце",		Расписание.ДеньВМесяце);
	Запрос.УстановитьПараметр("ДеньНеделиВМесяце",	Расписание.ДеньНеделиВМесяце);
	Запрос.УстановитьПараметр("ПериодПовтораДней",	?(Расписание.ПериодПовтораДней = 0,1,Расписание.ПериодПовтораДней));
	Запрос.УстановитьПараметр("ПериодНедель",		?(Расписание.ПериодНедель = 0,1,Расписание.ПериодНедель));
	
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	Календарь.Дата,
	|	Календарь.НомерМесяца,
	|	Календарь.НомерДняНеделиВМесяце,
	|	Календарь.НомерДняНеделиСКонцаМесяца,
	|	Календарь.НомерДняВМесяце,
	|	Календарь.НомерДняВМесяцеСКонцаМесяца,
	|	Календарь.НомерДняВНеделе,
	|	Календарь.НомерДняВПериоде,
	|	Календарь.НомерНеделиВПериоде
	|ИЗ
	|	Календарь КАК Календарь
	|ГДЕ
	|	ВЫБОР
	|			КОГДА &ДатаНачала = ДАТАВРЕМЯ(1, 1, 1, 0, 0, 0)
	|				ТОГДА ИСТИНА
	|			ИНАЧЕ Календарь.Дата >= &ДатаНачала
	|		КОНЕЦ
	|	И ВЫБОР
	|			КОГДА &ДатаКонца = ДАТАВРЕМЯ(1, 1, 1, 0, 0, 0)
	|				ТОГДА ИСТИНА
	|			ИНАЧЕ Календарь.Дата <= &ДатаКонца
	|		КОНЕЦ
	|	И Календарь.НомерДняВНеделе В(&ДниНедели)
	|	И Календарь.НомерМесяца В(&Месяцы)
	|	И ВЫБОР
	|			КОГДА &ДеньВМесяце = 0
	|				ТОГДА ИСТИНА
	|			ИНАЧЕ ВЫБОР
	|					КОГДА &ДеньВМесяце > 0
	|						ТОГДА Календарь.НомерДняВМесяце = &ДеньВМесяце
	|					ИНАЧЕ Календарь.НомерДняВМесяцеСКонцаМесяца = -&ДеньВМесяце
	|				КОНЕЦ
	|		КОНЕЦ
	|	И ВЫБОР
	|			КОГДА &ДеньНеделиВМесяце = 0
	|				ТОГДА ИСТИНА
	|			ИНАЧЕ ВЫБОР
	|					КОГДА &ДеньНеделиВМесяце > 0
	|						ТОГДА Календарь.НомерДняНеделиВМесяце = &ДеньНеделиВМесяце
	|					ИНАЧЕ Календарь.НомерДняНеделиСКонцаМесяца = -&ДеньНеделиВМесяце
	|				КОНЕЦ
	|		КОНЕЦ
	|	И Календарь.НомерДняВПериоде = &ПериодПовтораДней
	|	И Календарь.НомерНеделиВПериоде = &ПериодНедель";
	
	Выборка = Запрос.Выполнить().Выбрать();
	
	Результат = Новый Массив;
	
	Пока Выборка.Следующий() Цикл
		БлижайшаяДата = Выборка.Дата;
		ВремяОтсчета = '00010101';
		Если НачалоДня(БлижайшаяДата) = НачалоДня(ДатаОтсчета) Тогда
			ВремяОтсчета = ВремяОтсчета + (ДатаОтсчета-НачалоДня(ДатаОтсчета));
		КонецЕсли;
		
		ДатаИВремя = Неопределено;
		БлижайшееВремя = ПолучитьБлижайшееВремяИзРасписания(Расписание, ВремяОтсчета);
		Если БлижайшееВремя <> Неопределено Тогда
			ДатаИВремя = БлижайшаяДата + (БлижайшееВремя - '00010101');
		Иначе
			Если Выборка.Следующий() Тогда
				Время = ПолучитьБлижайшееВремяИзРасписания(Расписание);
				ДатаИВремя = Выборка.Дата + (Время - '00010101');
			КонецЕсли;
		КонецЕсли;
		
		Если ЗначениеЗаполнено(ДатаИВремя) И ДатаИВремя <= КонецПериода Тогда
			Результат.Добавить(ДатаИВремя);
		КонецЕсли;
	КонецЦикла;
	
	Возврат Результат;
	
КонецФункции

// Возвращает интервал времени в минутах, через который необходимо повторять проверку текущих напоминаний.
Функция ПолучитьИнтервалПроверкиНапоминаний(Пользователь = Неопределено)
	Интервал = ОбщегоНазначения.ХранилищеОбщихНастроекЗагрузить(
									"НастройкиНапоминаний", 
									"ИнтервалПроверкиНапоминаний", 
									1,
									,
									ПолучитьИмяПользователяИБ(Пользователь));
	Возврат Макс(Интервал, 1);
КонецФункции

Функция ПолучитьИмяПользователяИБ(Пользователь)
	Если Не ЗначениеЗаполнено(Пользователь) Тогда
		Возврат Неопределено;
	КонецЕсли;
	
	УстановитьПривилегированныйРежим(Истина);
	
	ПользовательИБ = ПользователиИнформационнойБазы.НайтиПоУникальномуИдентификатору(ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Пользователь, "ИдентификаторПользователяИБ"));
	Если ПользовательИБ = Неопределено Тогда
		Возврат Неопределено;
	КонецЕсли;
	
	Возврат ПользовательИБ.Имя;
КонецФункции

// Проверяет изменения реквизитов предметов, на которые есть пользовательская подписка,
// изменяет срок напоминания в случае необходимости.
//
Процедура ОбновитьНапоминанияПоПредметам(Предметы) Экспорт
	
	УстановитьПривилегированныйРежим(Истина);
	
	ТаблицаРезультата = НапоминанияПоПредметам(Предметы);
	
	Для Каждого СтрокаТаблицы Из ТаблицаРезультата Цикл
		ДатаПредмета = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(СтрокаТаблицы.Источник, СтрокаТаблицы.ИмяРеквизитаИсточника);
		Если (ДатаПредмета - СтрокаТаблицы.ИнтервалВремениНапоминания) <> СтрокаТаблицы.ВремяСобытия Тогда
			ОтключитьНапоминание(СтрокаТаблицы, Ложь);
			СтрокаТаблицы.СрокНапоминания = ДатаПредмета - СтрокаТаблицы.ИнтервалВремениНапоминания;
			СтрокаТаблицы.ВремяСобытия = ДатаПредмета;
			Если СтрокаТаблицы.Расписание.Получить() <> Неопределено Тогда
				СтрокаТаблицы.ПовторятьЕжегодно = Истина;
			КонецЕсли;
			
			ПараметрыНапоминания = ОбщегоНазначения.СтрокаТаблицыЗначенийВСтруктуру(СтрокаТаблицы);
			ПараметрыНапоминания.Расписание = СтрокаТаблицы.Расписание.Получить();
			Напоминание = СоздатьНапоминание(ПараметрыНапоминания);
			ПодключитьНапоминание(Напоминание);
		КонецЕсли;
	КонецЦикла;
	
КонецПроцедуры

// Параметры:
//  Предметы - Массив из ЛюбаяСсылка
// 
// Возвращаемое значение:
//  ТаблицаЗначений:
//   * Пользователь - СправочникСсылка.Пользователи
//   * ВремяСобытия - Дата
//   * Источник - ОпределяемыйТип.ПредметНапоминания
//   * СрокНапоминания - Дата
//   * Описание - Строка
//   * СпособУстановкиВремениНапоминания - ПеречислениеСсылка.СпособыУстановкиВремениНапоминания
//   * ИнтервалВремениНапоминания - Число
//   * ИмяРеквизитаИсточника - Строка
//   * Расписание - ХранилищеЗначения
//   * ПовторятьЕжегодно - Булево
//
Функция НапоминанияПоПредметам(Знач Предметы)
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	Напоминания.Пользователь,
	|	Напоминания.ВремяСобытия,
	|	Напоминания.Источник,
	|	Напоминания.СрокНапоминания,
	|	Напоминания.Описание,
	|	Напоминания.СпособУстановкиВремениНапоминания,
	|	Напоминания.ИнтервалВремениНапоминания,
	|	Напоминания.ИмяРеквизитаИсточника,
	|	Напоминания.Расписание,
	|	Напоминания.Идентификатор,
	|	ЛОЖЬ КАК ПовторятьЕжегодно
	|ИЗ
	|	РегистрСведений.НапоминанияПользователя КАК Напоминания
	|ГДЕ
	|	Напоминания.СпособУстановкиВремениНапоминания = ЗНАЧЕНИЕ(Перечисление.СпособыУстановкиВремениНапоминания.ОтносительноВремениПредмета)
	|	И Напоминания.Источник В(&Предметы)";
	
	Запрос.УстановитьПараметр("Предметы", Предметы);
	ТаблицаРезультата = Запрос.Выполнить().Выгрузить();
	
	Возврат ТаблицаРезультата
	
КонецФункции


// Обработчик подписки на событие ПриЗаписи объекта, по поводу которого можно создавать напоминания.
Процедура ПроверитьИзмененияДатВПредметеПриЗаписи(Источник, Отказ) Экспорт
	
	Если Источник.ОбменДанными.Загрузка Тогда
		Возврат;
	КонецЕсли;
	
	Если СтандартныеПодсистемыСервер.ЭтоИдентификаторОбъектаМетаданных(Источник) Тогда
		Возврат;
	КонецЕсли;
	
	Если ПолучитьФункциональнуюОпцию("ИспользоватьНапоминанияПользователя") Тогда
		ОбновитьНапоминанияПоПредметам(ОбщегоНазначенияКлиентСервер.ЗначениеВМассиве(Источник.Ссылка));
	КонецЕсли;
	
КонецПроцедуры

// Создает напоминание пользователя. Если по объекту уже есть напоминание, то сдвигает время напоминания на секунды вперед.
Процедура ПодключитьНапоминание(ПараметрыНапоминания, ОбновитьСрокНапоминания = Ложь) Экспорт
	
	НаборЗаписей = РегистрыСведений.НапоминанияПользователя.СоздатьНаборЗаписей();
	НаборЗаписей.Отбор.Пользователь.Установить(ПараметрыНапоминания.Пользователь);
	НаборЗаписей.Отбор.Источник.Установить(ПараметрыНапоминания.Источник);
	
	Блокировка = Новый БлокировкаДанных;
	ЭлементБлокировки = Блокировка.Добавить("РегистрСведений.НапоминанияПользователя");
	ЭлементБлокировки.УстановитьЗначение("Пользователь", ПараметрыНапоминания.Пользователь);
	ЭлементБлокировки.УстановитьЗначение("Источник", ПараметрыНапоминания.Источник);
	
	Если ОбновитьСрокНапоминания Тогда
		НаборЗаписей.Отбор.ВремяСобытия.Установить(ПараметрыНапоминания.ВремяСобытия);
		ЭлементБлокировки.УстановитьЗначение("ВремяСобытия", ПараметрыНапоминания.ВремяСобытия);
	КонецЕсли;
	
	НачатьТранзакцию();
	Попытка
		Блокировка.Заблокировать();
		НаборЗаписей.Прочитать();
		
		Если ОбновитьСрокНапоминания Тогда
			Для Каждого Запись Из НаборЗаписей Цикл
				ЗаполнитьЗначенияСвойств(Запись, ПараметрыНапоминания);
			КонецЦикла;
		Иначе
			Если НаборЗаписей.Количество() > 0 Тогда
				ЗанятоеВремя = НаборЗаписей.Выгрузить(,"ВремяСобытия").ВыгрузитьКолонку("ВремяСобытия");
				Пока ЗанятоеВремя.Найти(ПараметрыНапоминания.ВремяСобытия) <> Неопределено Цикл
					ПараметрыНапоминания.ВремяСобытия = ПараметрыНапоминания.ВремяСобытия + 1;
				КонецЦикла;
			КонецЕсли;
			НоваяЗапись = НаборЗаписей.Добавить();
			ЗаполнитьЗначенияСвойств(НоваяЗапись, ПараметрыНапоминания);
		КонецЕсли;
		
		Если НаборЗаписей.Количество() > 0 Тогда
			НаборЗаписей.Записать();
		КонецЕсли;
		
		ЗафиксироватьТранзакцию();
	Исключение
		ОтменитьТранзакцию();
		ВызватьИсключение;
	КонецПопытки;
	
КонецПроцедуры

// Отключает напоминание, если оно есть. Если напоминание периодическое, подключает его на ближайшую дату по расписанию.
Процедура ОтключитьНапоминание(ПараметрыНапоминания, ПодключатьПоРасписанию = Истина) Экспорт
	
	ТекстЗапроса = 
	"ВЫБРАТЬ
	|	НапоминанияПользователя.Пользователь КАК Пользователь,
	|	НапоминанияПользователя.ВремяСобытия КАК ВремяСобытия,
	|	НапоминанияПользователя.Источник КАК Источник,
	|	НапоминанияПользователя.СрокНапоминания КАК СрокНапоминания,
	|	НапоминанияПользователя.Описание КАК Описание,
	|	НапоминанияПользователя.СпособУстановкиВремениНапоминания КАК СпособУстановкиВремениНапоминания,
	|	НапоминанияПользователя.Расписание КАК Расписание,
	|	НапоминанияПользователя.ИнтервалВремениНапоминания КАК ИнтервалВремениНапоминания,
	|	НапоминанияПользователя.ИмяРеквизитаИсточника КАК ИмяРеквизитаИсточника,
	|	НапоминанияПользователя.Идентификатор КАК Идентификатор
	|ИЗ
	|	РегистрСведений.НапоминанияПользователя КАК НапоминанияПользователя
	|ГДЕ
	|	НапоминанияПользователя.Пользователь = &Пользователь
	|	И НапоминанияПользователя.ВремяСобытия = &ВремяСобытия
	|	И НапоминанияПользователя.Источник = &Источник";
	
	Запрос = Новый Запрос(ТекстЗапроса);
	Запрос.УстановитьПараметр("Пользователь", ПараметрыНапоминания.Пользователь);
	Запрос.УстановитьПараметр("ВремяСобытия", ПараметрыНапоминания.ВремяСобытия);
	Запрос.УстановитьПараметр("Источник", ПараметрыНапоминания.Источник);
	
	Блокировка = Новый БлокировкаДанных;
	ЭлементБлокировки = Блокировка.Добавить("РегистрСведений.НапоминанияПользователя");
	ЭлементБлокировки.УстановитьЗначение("Пользователь", ПараметрыНапоминания.Пользователь);
	ЭлементБлокировки.УстановитьЗначение("Источник", ПараметрыНапоминания.Источник);
	ЭлементБлокировки.УстановитьЗначение("ВремяСобытия", ПараметрыНапоминания.ВремяСобытия);
	
	НачатьТранзакцию();
	Попытка
		Блокировка.Заблокировать();
		
		РезультатЗапроса = Запрос.Выполнить().Выгрузить();
		Напоминание = Неопределено;
		Если РезультатЗапроса.Количество() > 0 Тогда
			Напоминание = РезультатЗапроса[0];
		КонецЕсли;
		
		// Удаляем существующую запись.
		НаборЗаписей = РегистрыСведений.НапоминанияПользователя.СоздатьНаборЗаписей();
		НаборЗаписей.Отбор.Пользователь.Установить(ПараметрыНапоминания.Пользователь);
		НаборЗаписей.Отбор.Источник.Установить(ПараметрыНапоминания.Источник);
		НаборЗаписей.Отбор.ВремяСобытия.Установить(ПараметрыНапоминания.ВремяСобытия);
		НаборЗаписей.Записать();
		
		// Подключаем следующее напоминание по расписанию.
		СледующаяДатаПоРасписанию = Неопределено;
		ОпределенаСледующаяДатаПоРасписанию = Ложь;
		
		Если ПодключатьПоРасписанию И Напоминание <> Неопределено Тогда
			Расписание = Напоминание.Расписание.Получить();
			Если Расписание <> Неопределено Тогда
				Если Расписание.ПериодПовтораДней > 0 Тогда
					СледующаяДатаПоРасписанию = ПолучитьБлижайшуюДатуСобытияПоРасписанию(Расписание, ПараметрыНапоминания.ВремяСобытия + 1);
				КонецЕсли;
				ОпределенаСледующаяДатаПоРасписанию = СледующаяДатаПоРасписанию <> Неопределено;
			КонецЕсли;
			
			Если ОпределенаСледующаяДатаПоРасписанию Тогда
				Напоминание.ВремяСобытия = СледующаяДатаПоРасписанию;
				Напоминание.СрокНапоминания = Напоминание.ВремяСобытия - Напоминание.ИнтервалВремениНапоминания;
				ПодключитьНапоминание(Напоминание);
			КонецЕсли;
		КонецЕсли;
		
		ЗафиксироватьТранзакцию();
	Исключение
		ОтменитьТранзакцию();
		ВызватьИсключение;
	КонецПопытки;
	
КонецПроцедуры

// Возвращаемое значение:
//  Структура:
//   * Пользователь - СправочникСсылка.Пользователи
//   * ВремяСобытия - Дата
//   * Источник - ОпределяемыйТип.ПредметНапоминания
//   * СрокНапоминания - Дата
//   * Описание - Строка
//   * СпособУстановкиВремениНапоминания - ПеречислениеСсылка.СпособыУстановкиВремениНапоминания
//   * ИнтервалВремениНапоминания - Число
//   * ИмяРеквизитаИсточника - Строка
//   * Расписание - ХранилищеЗначения - значение типа РасписаниеРегламентногоЗадания
//   * ПредставлениеИсточника - Строка
//   * Идентификатор - Строка
//
Функция ПодключитьПроизвольноеНапоминание(Текст, ВремяСобытия, ИнтервалДоСобытия = 0, Предмет = Неопределено, Идентификатор = Неопределено) Экспорт
	ПараметрыНапоминания = Новый Структура;
	ПараметрыНапоминания.Вставить("Описание", Текст);
	Если ТипЗнч(ВремяСобытия) = Тип("РасписаниеРегламентногоЗадания") Тогда
		ПараметрыНапоминания.Вставить("Расписание", ВремяСобытия);
	ИначеЕсли ТипЗнч(ВремяСобытия) = Тип("Строка") Тогда
		ПараметрыНапоминания.Вставить("ИмяРеквизитаИсточника", ВремяСобытия);
	Иначе
		ПараметрыНапоминания.Вставить("ВремяСобытия", ВремяСобытия);
	КонецЕсли;
	ПараметрыНапоминания.Вставить("ИнтервалВремениНапоминания", ИнтервалДоСобытия);
	ПараметрыНапоминания.Вставить("Источник", Предмет);
	ПараметрыНапоминания.Вставить("Идентификатор", Идентификатор);
	
	Напоминание = СоздатьНапоминание(ПараметрыНапоминания);
	ПодключитьНапоминание(Напоминание);
	
	Возврат Напоминание;
КонецФункции

Функция ПодключитьНапоминаниеДоВремениПредмета(Текст, Интервал, Предмет, ИмяРеквизита, ПовторятьЕжегодно = Ложь) Экспорт
	ПараметрыНапоминания = Новый Структура;
	ПараметрыНапоминания.Вставить("Описание", Текст);
	ПараметрыНапоминания.Вставить("Источник", Предмет);
	ПараметрыНапоминания.Вставить("ИмяРеквизитаИсточника", ИмяРеквизита);
	ПараметрыНапоминания.Вставить("ИнтервалВремениНапоминания", Интервал);
	ПараметрыНапоминания.Вставить("ПовторятьЕжегодно", ПовторятьЕжегодно);
	
	Напоминание = СоздатьНапоминание(ПараметрыНапоминания);
	ПодключитьНапоминание(Напоминание);
	
	Возврат Напоминание;
КонецФункции

// Возвращает структуру нового напоминания для последующего подключения.
Функция СоздатьНапоминание(ПараметрыНапоминания)
	
	Напоминание = НапоминанияПользователяКлиентСервер.ОписаниеНапоминания(ПараметрыНапоминания, Истина);
	
	Если Не ЗначениеЗаполнено(Напоминание.Пользователь) Тогда
		Напоминание.Пользователь = Пользователи.ТекущийПользователь();
	КонецЕсли;
	
	Если Не ЗначениеЗаполнено(Напоминание.СпособУстановкиВремениНапоминания) Тогда
		Если ЗначениеЗаполнено(Напоминание.Источник) И Не ПустаяСтрока(Напоминание.ИмяРеквизитаИсточника) Тогда
			Напоминание.СпособУстановкиВремениНапоминания = Перечисления.СпособыУстановкиВремениНапоминания.ОтносительноВремениПредмета;
		ИначеЕсли Напоминание.Расписание <> Неопределено Тогда
			Напоминание.СпособУстановкиВремениНапоминания = Перечисления.СпособыУстановкиВремениНапоминания.Периодически;
		ИначеЕсли Не ЗначениеЗаполнено(Напоминание.ВремяСобытия) Тогда
			Напоминание.СпособУстановкиВремениНапоминания = Перечисления.СпособыУстановкиВремениНапоминания.ОтносительноТекущегоВремени;
		Иначе
			Напоминание.СпособУстановкиВремениНапоминания = Перечисления.СпособыУстановкиВремениНапоминания.ВУказанноеВремя;
		КонецЕсли;
	КонецЕсли;
	
	Если Напоминание.СпособУстановкиВремениНапоминания = Перечисления.СпособыУстановкиВремениНапоминания.ОтносительноВремениПредмета Тогда
		Напоминание.ВремяСобытия = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Напоминание.Источник, Напоминание.ИмяРеквизитаИсточника);
		Напоминание.СрокНапоминания = Напоминание.ВремяСобытия - ?(ЗначениеЗаполнено(Напоминание.ВремяСобытия), Напоминание.ИнтервалВремениНапоминания, 0);
	ИначеЕсли Напоминание.СпособУстановкиВремениНапоминания = Перечисления.СпособыУстановкиВремениНапоминания.ОтносительноТекущегоВремени Тогда
		Напоминание.СпособУстановкиВремениНапоминания = Перечисления.СпособыУстановкиВремениНапоминания.ВУказанноеВремя;
		Напоминание.ВремяСобытия = ТекущаяДатаСеанса() + Напоминание.ИнтервалВремениНапоминания;
	ИначеЕсли Напоминание.СпособУстановкиВремениНапоминания = Перечисления.СпособыУстановкиВремениНапоминания.ВУказанноеВремя Тогда
		Напоминание.СрокНапоминания = Напоминание.ВремяСобытия - Напоминание.ИнтервалВремениНапоминания;
	КонецЕсли;
	
	Если Не ЗначениеЗаполнено(Напоминание.СрокНапоминания) Тогда
		Напоминание.СрокНапоминания = Напоминание.ВремяСобытия;
	КонецЕсли;
	
	Если Напоминание.ПовторятьЕжегодно Тогда
		Если ЗначениеЗаполнено(Напоминание.ВремяСобытия) Тогда
			Напоминание.Расписание = НапоминанияПользователяКлиентСервер.ЕжегодноеРасписание(Напоминание.ВремяСобытия);
		КонецЕсли;
	КонецЕсли;
	
	Если Напоминание.Расписание <> Неопределено Тогда
		Напоминание.ВремяСобытия = ПолучитьБлижайшуюДатуСобытияПоРасписанию(Напоминание.Расписание);
		Если Напоминание.ВремяСобытия = Неопределено Тогда
			Напоминание.ВремяСобытия = '00010101';
		КонецЕсли;
		Напоминание.СрокНапоминания = Напоминание.ВремяСобытия - Напоминание.ИнтервалВремениНапоминания;
	КонецЕсли;
	
	Напоминание.Расписание = Новый ХранилищеЗначения(Напоминание.Расписание, Новый СжатиеДанных(9));
	
	Возврат Напоминание;
	
КонецФункции

// Прекращает просроченные периодические напоминания.
Процедура АктуализироватьСписокНапоминаний()
	
	ТекстЗапроса =
	"ВЫБРАТЬ РАЗРЕШЕННЫЕ
	|	Напоминания.Пользователь КАК Пользователь,
	|	Напоминания.ВремяСобытия КАК ВремяСобытия,
	|	Напоминания.Источник КАК Источник,
	|	Напоминания.СрокНапоминания КАК СрокНапоминания,
	|	Напоминания.Описание КАК Описание,
	|	Напоминания.СпособУстановкиВремениНапоминания КАК СпособУстановкиВремениНапоминания,
	|	Напоминания.ИнтервалВремениНапоминания КАК ИнтервалВремениНапоминания,
	|	Напоминания.ИмяРеквизитаИсточника КАК ИмяРеквизитаИсточника,
	|	Напоминания.Расписание КАК Расписание,
	|	Напоминания.ПредставлениеИсточника КАК ПредставлениеИсточника,
	|	Напоминания.Идентификатор КАК Идентификатор
	|ИЗ
	|	РегистрСведений.НапоминанияПользователя КАК Напоминания
	|ГДЕ
	|	Напоминания.ВремяСобытия <= &ТекущаяДата
	|	И Напоминания.Пользователь = &Пользователь";
	
	Запрос = Новый Запрос(ТекстЗапроса);
	
	Запрос.УстановитьПараметр("ТекущаяДата", ТекущаяДатаСеанса());
	Запрос.УстановитьПараметр("Пользователь", Пользователи.ТекущийПользователь());
	
	УстановитьПривилегированныйРежим(Истина);
	СписокНапоминаний = Запрос.Выполнить().Выгрузить();
	УстановитьПривилегированныйРежим(Ложь);
	
	Для Каждого Напоминание Из СписокНапоминаний Цикл
		Расписание = Напоминание.Расписание.Получить();
		Если Расписание = Неопределено Тогда
			Продолжить;
		КонецЕсли;
		
		ГрафикСобытияНаГод = ГрафикСобытия(Расписание, Напоминание.ВремяСобытия, ДобавитьМесяц(Напоминание.ВремяСобытия, 12) - 1);
		ПодошедшееВремяСобытия = ГрафикСобытия(Расписание, Напоминание.ВремяСобытия + 1, ТекущаяДатаСеанса());
		
		// - подошло следующее время события по расписанию;
		Если ПодошедшееВремяСобытия.Количество() > 0
			// - указано "Время завершения" в расписании регламентного задания и оно просрочено;
			Или ЗначениеЗаполнено(Расписание.ВремяЗавершения) И ТекущаяДатаСеанса() > (Напоминание.ВремяСобытия + (Расписание.ВремяЗавершения - Расписание.ВремяНачала))
			// - напоминание ежегодное, но уже прошел месяц со времени события;
			Или ГрафикСобытияНаГод.Количество() = 1 И ТекущаяДатаСеанса() > ДобавитьМесяц(Напоминание.ВремяСобытия, 1)
			// - напоминание ежемесячное, но уже прошла неделя со времени события.
			Или ГрафикСобытияНаГод.Количество() = 12 И ТекущаяДатаСеанса() > Напоминание.ВремяСобытия + 60*60*24*7 Тогда
				НачатьТранзакцию();
				Попытка
					Если ПодошедшееВремяСобытия.Количество() > 0 Тогда
						ОтключитьНапоминание(Напоминание, Ложь);
						
						ПараметрыНапоминания = ОбщегоНазначения.СтрокаТаблицыЗначенийВСтруктуру(Напоминание);
						ПараметрыНапоминания.Расписание = Напоминание.Расписание.Получить();
						Напоминание = СоздатьНапоминание(ПараметрыНапоминания);
						Напоминание.ВремяСобытия = ПодошедшееВремяСобытия[ПодошедшееВремяСобытия.ВГраница()];
						Напоминание.СрокНапоминания = Напоминание.ВремяСобытия - Напоминание.ИнтервалВремениНапоминания;
						
						ПодключитьНапоминание(Напоминание);
					КонецЕсли;
					ОтключитьНапоминание(Напоминание, Истина);
					ЗафиксироватьТранзакцию();
				Исключение
					ОтменитьТранзакцию();
					ЗаписьЖурналаРегистрации(НСтр("ru = 'Напоминания пользователя'", ОбщегоНазначения.КодОсновногоЯзыка()),
						УровеньЖурналаРегистрации.Ошибка, Метаданные.РегистрыСведений.НапоминанияПользователя, , ПодробноеПредставлениеОшибки(ИнформацияОбОшибке()));
				КонецПопытки;
		КонецЕсли;
	КонецЦикла;
	
КонецПроцедуры

// Возвращаемое значение:
//  Массив из Структура:
//   * Пользователь - СправочникСсылка.Пользователи
//   * ВремяСобытия - Дата
//   * Источник - ОпределяемыйТип.ПредметНапоминания
//   * СрокНапоминания - Дата
//   * Описание - Строка
//   * ИндексКартинки - Число
//
Функция СписокТекущихНапоминанийПользователя() Экспорт
	
	АктуализироватьСписокНапоминаний();
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ РАЗРЕШЕННЫЕ
	|	Напоминания.Пользователь КАК Пользователь,
	|	Напоминания.ВремяСобытия КАК ВремяСобытия,
	|	Напоминания.Источник КАК Источник,
	|	Напоминания.СрокНапоминания КАК СрокНапоминания,
	|	Напоминания.Описание КАК Описание,
	|	2 КАК ИндексКартинки
	|ИЗ
	|	РегистрСведений.НапоминанияПользователя КАК Напоминания
	|ГДЕ
	|	Напоминания.СрокНапоминания <= &ТекущаяДата
	|	И Напоминания.Пользователь = &Пользователь
	|
	|УПОРЯДОЧИТЬ ПО
	|	ВремяСобытия";
	
	Запрос.УстановитьПараметр("ТекущаяДата", ТекущаяДатаСеанса() + 30*60);// +30 минут для кэша
	Запрос.УстановитьПараметр("Пользователь", Пользователи.ТекущийПользователь());
	
	УстановитьПривилегированныйРежим(Истина);
	Результат = ОбщегоНазначения.ТаблицаЗначенийВМассив(Запрос.Выполнить().Выгрузить());
	
	Возврат Результат;
	
КонецФункции

#КонецОбласти
