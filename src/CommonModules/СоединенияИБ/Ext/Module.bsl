﻿///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2023, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область ПрограммныйИнтерфейс

////////////////////////////////////////////////////////////////////////////////
// Блокировка и завершение соединений с ИБ.

// Устанавливает блокировку соединений ИБ.
// Если вызывается из сеанса с установленными значениями разделителей,
// то устанавливает блокировку сеансов области данных.
//
// Параметры:
//  ТекстСообщения           - Строка - текст, который будет частью сообщения об ошибке
//                                      при попытке установки соединения с заблокированной
//                                      информационной базой.
// 
//  КодРазрешения            - Строка - строка, которая должна быть добавлена к параметру
//                                      командной строки "/uc" или к параметру строки
//                                      соединения "uc", чтобы установить соединение с
//                                      информационной базой несмотря на блокировку.
//                                      Не применимо для блокировки сеансов области данных.
//  ОжиданиеНачалаБлокировки - Число -  время отсрочки начала блокировки в минутах.
//  ДлительностьБлокировки   - Число -  время длительности блокировки в минутах.
//
// Возвращаемое значение:
//   Булево   - Истина, если блокировка установлена успешно.
//              Ложь, если для выполнения блокировки недостаточно прав.
//
Функция УстановитьБлокировкуСоединений(Знач ТекстСообщения = "", Знач КодРазрешения = "КодРазрешения", // АПК:142 Для сохранения обратной совместимости.
	Знач ОжиданиеНачалаБлокировки = 0, Знач ДлительностьБлокировки = 0) Экспорт
	
	Если ОбщегоНазначения.РазделениеВключено() И ОбщегоНазначения.ДоступноИспользованиеРазделенныхДанных() Тогда
		
		Если Не Пользователи.ЭтоПолноправныйПользователь() Тогда
			Возврат Ложь;
		КонецЕсли;
		
		Блокировка = НовыеПараметрыБлокировкиСоединений();
		Блокировка.Установлена = Истина;
		Блокировка.Начало = ТекущаяДатаСеанса() + ОжиданиеНачалаБлокировки * 60;
		Блокировка.Сообщение = СформироватьСообщениеБлокировки(ТекстСообщения, КодРазрешения);
		Блокировка.Эксклюзивная = Пользователи.ЭтоПолноправныйПользователь(, Истина);
		
		Если ДлительностьБлокировки > 0 Тогда 
			Блокировка.Конец = Блокировка.Начало + ДлительностьБлокировки * 60;
		КонецЕсли;
		
		УстановитьБлокировкуСеансовОбластиДанных(Блокировка);
		
		Возврат Истина;
	Иначе
		Если Не Пользователи.ЭтоПолноправныйПользователь(, Истина) Тогда
			Возврат Ложь;
		КонецЕсли;
		
		Блокировка = Новый БлокировкаСеансов;
		Блокировка.Установлена = Истина;
		Блокировка.Начало = ТекущаяДатаСеанса() + ОжиданиеНачалаБлокировки * 60;
		Блокировка.КодРазрешения = КодРазрешения;
		Блокировка.Параметр = СерверныеОповещения.КлючСеанса();
		Блокировка.Сообщение = СформироватьСообщениеБлокировки(ТекстСообщения, КодРазрешения);
		
		Если ДлительностьБлокировки > 0 Тогда 
			Блокировка.Конец = Блокировка.Начало + ДлительностьБлокировки * 60;
		КонецЕсли;
		
		УстановитьБлокировкуСеансов(Блокировка);
	
		УстановитьПривилегированныйРежим(Истина);
		ОтправитьСерверноеОповещениеОбУстановкеБлокировки();
		УстановитьПривилегированныйРежим(Ложь);
		
		Возврат Истина;
	КонецЕсли;
	
КонецФункции

// Определить, установлена ли блокировка соединений при пакетном 
// обновлении конфигурации информационной базы.
//
// Возвращаемое значение:
//    Булево - Истина, если установлена, Ложь - иначе.
//
Функция УстановленаБлокировкаСоединений() Экспорт
	
	ПараметрыБлокировки = ТекущиеПараметрыБлокировкиСоединений();
	Возврат ПараметрыБлокировки.УстановленаБлокировкаСоединений;
	
КонецФункции

// Получить параметры блокировки соединений ИБ для использования на стороне клиента.
//
// Параметры:
//    ПолучитьКоличествоСеансов - Булево - если Истина, то в возвращаемой структуре
//                                         заполняется поле КоличествоСеансов.
//
// Возвращаемое значение:
//   Структура:
//     * Установлена       - Булево - Истина, если установлена блокировка, Ложь - иначе. 
//     * Начало            - Дата   - дата начала блокировки. 
//     * Конец             - Дата   - дата окончания блокировки. 
//     * Сообщение         - Строка - сообщение пользователю. 
//     * ИнтервалОжиданияЗавершенияРаботыПользователей - Число - интервал в секундах.
//     * КоличествоСеансов - Число  - 0, если параметр ПолучитьКоличествоСеансов = Ложь.
//     * ТекущаяДатаСеанса - Дата   - текущая дата сеанса.
//
Функция ПараметрыБлокировкиСеансов(Знач ПолучитьКоличествоСеансов = Ложь) Экспорт
	
	ПараметрыБлокировки = ТекущиеПараметрыБлокировкиСоединений();
	Возврат ПараметрыБлокировкиСеансовРасширенные(ПолучитьКоличествоСеансов, ПараметрыБлокировки);
	
КонецФункции

// Снять блокировку информационной базы.
//
// Возвращаемое значение:
//   Булево   - Истина, если операция выполнена успешно.
//              Ложь, если для выполнения операции недостаточно прав.
//
Функция РазрешитьРаботуПользователей() Экспорт
	
	Если ОбщегоНазначения.РазделениеВключено() И ОбщегоНазначения.ДоступноИспользованиеРазделенныхДанных() Тогда
		
		Если Не Пользователи.ЭтоПолноправныйПользователь() Тогда
			Возврат Ложь;
		КонецЕсли;
		
		ПараметрыБлокировки = ПолучитьБлокировкуСеансовОбластиДанных();
		Если ПараметрыБлокировки.Установлена Тогда
			ПараметрыБлокировки.Установлена = Ложь;
			УстановитьБлокировкуСеансовОбластиДанных(ПараметрыБлокировки);
		КонецЕсли;
		Возврат Истина;
		
	КонецЕсли;
	
	Если НЕ Пользователи.ЭтоПолноправныйПользователь(, Истина) Тогда
		Возврат Ложь;
	КонецЕсли;
	
	ПараметрыБлокировки = ПолучитьБлокировкуСеансов();
	Если ПараметрыБлокировки.Установлена Тогда
		ПараметрыБлокировки.Установлена = Ложь;
		
		УстановитьБлокировкуСеансов(ПараметрыБлокировки);
		
		УстановитьПривилегированныйРежим(Истина);
		ОтправитьСерверноеОповещениеОбУстановкеБлокировки();
		УстановитьПривилегированныйРежим(Ложь);
	КонецЕсли;
	
	Возврат Истина;
	
КонецФункции

// Возвращает информацию о текущих соединениях с информационной базой.
// При необходимости записывает сообщение в журнал регистрации.
//
// Параметры:
//    ПолучатьСтрокуСоединения - Булево - признак необходимости добавления в возвращаемое значение строки соединения.
//    СообщенияДляЖурналаРегистрации - СписокЗначений - если параметр не пустой, то будет выполнена запись событий
//                                                      из списка в журнал регистрации.
//    ПортКластера - Число - нестандартный порт кластера серверов.
//
// Возвращаемое значение:
//    Структура:
//        * НаличиеАктивныхСоединений - Булево - признак наличия активных соединений.
//        * НаличиеCOMСоединений - Булево - признак наличия com соединений.
//        * НаличиеСоединенияКонфигуратором - Булево - признак наличия соединения конфигуратора.
//        * ЕстьАктивныеПользователи - Булево - признак наличия активных пользователей.
//        * СтрокаСоединенияИнформационнойБазы - Строка - строка соединения информационной базы. Свойство будет,
//                                                            только если параметр ПолучатьСтрокуСоединения был
//                                                            установлен в значение Истина.
//
Функция ИнформацияОСоединениях(ПолучатьСтрокуСоединения = Ложь,
	СообщенияДляЖурналаРегистрации = Неопределено, ПортКластера = 0) Экспорт
	
	УстановитьПривилегированныйРежим(Истина);
	
	Результат = Новый Структура();
	Результат.Вставить("НаличиеАктивныхСоединений", Ложь);
	Результат.Вставить("НаличиеCOMСоединений", Ложь);
	Результат.Вставить("НаличиеСоединенияКонфигуратором", Ложь);
	Результат.Вставить("ЕстьАктивныеПользователи", Ложь);
	
	Если ПользователиИнформационнойБазы.ПолучитьПользователей().Количество() > 0 Тогда
		Результат.ЕстьАктивныеПользователи = Истина;
	КонецЕсли;
	
	Если ПолучатьСтрокуСоединения Тогда
		Результат.Вставить("СтрокаСоединенияИнформационнойБазы", СтрокаСоединенияИнформационнойБазы());
	КонецЕсли;
		
	ЖурналРегистрации.ЗаписатьСобытияВЖурналРегистрации(СообщенияДляЖурналаРегистрации);
	
	МассивСеансов = ПолучитьСеансыИнформационнойБазы();
	Если МассивСеансов.Количество() = 1 Тогда
		Возврат Результат;
	КонецЕсли;
	
	Результат.НаличиеАктивныхСоединений = Истина;
	
	Для Каждого Сеанс Из МассивСеансов Цикл
		Если ВРег(Сеанс.ИмяПриложения) = ВРег("COMConnection") Тогда // COM соединение
			Результат.НаличиеCOMСоединений = Истина;
		ИначеЕсли ВРег(Сеанс.ИмяПриложения) = ВРег("Designer") Тогда // Конфигуратор
			Результат.НаличиеСоединенияКонфигуратором = Истина;
		КонецЕсли;
	КонецЦикла;
	
	Возврат Результат;
	
КонецФункции

////////////////////////////////////////////////////////////////////////////////
// Блокировка сеансов областей данных.

// Получить пустую структуру с параметрами блокировки сеансов области данных.
// 
// Возвращаемое значение:
//   Структура:
//     * Начало         - Дата   - время начала действия блокировки.
//     * Конец          - Дата   - время завершения действия блокировки.
//     * Сообщение      - Строка - сообщения для пользователей, выполняющих вход в заблокированную область данных.
//     * Установлена    - Булево - признак того, что блокировка установлена.
//     * Эксклюзивная   - Булево - блокировка не может быть изменена администратором приложения.
//
Функция НовыеПараметрыБлокировкиСоединений() Экспорт
	
	Результат = Новый Структура;
	Результат.Вставить("Конец", Дата(1,1,1));
	Результат.Вставить("Начало", Дата(1,1,1));
	Результат.Вставить("Сообщение", "");
	Результат.Вставить("Установлена", Ложь);
	Результат.Вставить("Эксклюзивная", Ложь);
	
	Возврат Результат;
	
КонецФункции

// Установить блокировку сеансов области данных.
// 
// Параметры:
//   Параметры         - см. НовыеПараметрыБлокировкиСоединений
//   ПоМестномуВремени - Булево - время начала и окончания блокировки указаны в местном времени сеанса.
//                                Если Ложь, то в универсальном времени.
//   ОбластьДанных - Число - номер области данных, для которой устанавливается блокировка.
//     При вызове из сеанса, в котором заданы значения разделителей, может быть передано только значение,
//       совпадающее со значением разделителя в сеансе (или опущено).
//     При вызове из сеанса, в котором не заданы значения разделителей, значение параметра не может быть опущено.
//
Процедура УстановитьБлокировкуСеансовОбластиДанных(Знач Параметры, Знач ПоМестномуВремени = Истина, Знач ОбластьДанных = -1) Экспорт
	
	Если Не Пользователи.ЭтоПолноправныйПользователь() Тогда
		ВызватьИсключение НСтр("ru = 'Недостаточно прав для выполнения операции';
								|en = 'Not enough rights to perform the operation.'");
	КонецЕсли;
	
	// Для обратной совместимости.
	ПараметрыБлокировкиСоединений = НовыеПараметрыБлокировкиСоединений();
	ЗаполнитьЗначенияСвойств(ПараметрыБлокировкиСоединений, Параметры); 
	Параметры = ПараметрыБлокировкиСоединений;
	 
	Если Параметры.Эксклюзивная И Не Пользователи.ЭтоПолноправныйПользователь(, Истина) Тогда
		ВызватьИсключение НСтр("ru = 'Недостаточно прав для выполнения операции';
								|en = 'Not enough rights to perform the operation.'");
	КонецЕсли;
	
	Если ОбщегоНазначения.ДоступноИспользованиеРазделенныхДанных() Тогда
		
		МодульРаботаВМоделиСервиса = ОбщегоНазначения.ОбщийМодуль("РаботаВМоделиСервиса");
		ЗначениеРазделителяСеанса = МодульРаботаВМоделиСервиса.ЗначениеРазделителяСеанса();
		
		Если ОбластьДанных = -1 Тогда
			ОбластьДанных = ЗначениеРазделителяСеанса;
		ИначеЕсли ОбластьДанных <> ЗначениеРазделителяСеанса Тогда
			ВызватьИсключение НСтр("ru = 'Из сеанса с используемыми значениями разделителей нельзя установить блокировку сеансов области данных, отличной от используемой в сеансе.';
									|en = 'Cannot set a session lock for a data area that is different from the session data area because the session uses separator values.'");
		КонецЕсли;
		
	ИначеЕсли ОбластьДанных = -1 Тогда
		ВызватьИсключение НСтр("ru = 'Невозможно установить блокировку сеансов области данных - не указана область данных.';
								|en = 'Cannot lock data area sessions because the data area is not specified.'");
	КонецЕсли;
	
	УстановитьПривилегированныйРежим(Истина);
	НачатьТранзакцию();
	Попытка
		
		БлокировкаДанных = Новый БлокировкаДанных;
		ЭлементБлокировки = БлокировкаДанных.Добавить("РегистрСведений.БлокировкиСеансовОбластейДанных");
		ЭлементБлокировки.УстановитьЗначение("ОбластьДанныхВспомогательныеДанные", ОбластьДанных);
		БлокировкаДанных.Заблокировать();
		
		НаборБлокировок = РегистрыСведений.БлокировкиСеансовОбластейДанных.СоздатьНаборЗаписей();
		НаборБлокировок.Отбор.ОбластьДанныхВспомогательныеДанные.Установить(ОбластьДанных);
		НаборБлокировок.Прочитать();
		НаборБлокировок.Очистить();
		Если Параметры.Установлена Тогда 
			Блокировка = НаборБлокировок.Добавить();
			Блокировка.ОбластьДанныхВспомогательныеДанные = ОбластьДанных;
			Блокировка.НачалоБлокировки = ?(ПоМестномуВремени И ЗначениеЗаполнено(Параметры.Начало), 
				УниверсальноеВремя(Параметры.Начало), Параметры.Начало);
			Блокировка.КонецБлокировки = ?(ПоМестномуВремени И ЗначениеЗаполнено(Параметры.Конец), 
				УниверсальноеВремя(Параметры.Конец), Параметры.Конец);
			Блокировка.СообщениеБлокировки = Параметры.Сообщение;
			Блокировка.Эксклюзивная = Параметры.Эксклюзивная;
		КонецЕсли;
		НаборБлокировок.Записать();
		
		ЗафиксироватьТранзакцию();
	Исключение
		ОтменитьТранзакцию();
		ВызватьИсключение;
	КонецПопытки;
	
	ОтправитьСерверноеОповещениеОбУстановкеБлокировки();
	
КонецПроцедуры

// Получить информацию о блокировке сеансов области данных.
// 
// Параметры:
//   ПоМестномуВремени - Булево - время начала и окончания блокировки необходимо вернуть 
//                                в местном времени сеанса. Если Ложь, то 
//                                возвращается в универсальном времени.
//
// Возвращаемое значение:
//   см. НовыеПараметрыБлокировкиСоединений.
//
Функция ПолучитьБлокировкуСеансовОбластиДанных(Знач ПоМестномуВремени = Истина) Экспорт
	
	Результат = НовыеПараметрыБлокировкиСоединений();
	Если Не ОбщегоНазначения.РазделениеВключено() Или Не ОбщегоНазначения.ДоступноИспользованиеРазделенныхДанных() Тогда
		Возврат Результат;
	КонецЕсли;
	
	Если Не Пользователи.ЭтоПолноправныйПользователь() Тогда
		ВызватьИсключение НСтр("ru = 'Недостаточно прав для выполнения операции';
								|en = 'Not enough rights to perform the operation.'");
	КонецЕсли;
	
	МодульРаботаВМоделиСервиса = ОбщегоНазначения.ОбщийМодуль("РаботаВМоделиСервиса");
	
	УстановитьПривилегированныйРежим(Истина);
	НаборБлокировок = РегистрыСведений.БлокировкиСеансовОбластейДанных.СоздатьНаборЗаписей();
	НаборБлокировок.Отбор.ОбластьДанныхВспомогательныеДанные.Установить(
		МодульРаботаВМоделиСервиса.ЗначениеРазделителяСеанса());
	НаборБлокировок.Прочитать();
	Если НаборБлокировок.Количество() = 0 Тогда
		Возврат Результат;
	КонецЕсли;
	Блокировка = НаборБлокировок[0];
	Результат.Начало = ?(ПоМестномуВремени И ЗначениеЗаполнено(Блокировка.НачалоБлокировки), 
		МестноеВремя(Блокировка.НачалоБлокировки), Блокировка.НачалоБлокировки);
	Результат.Конец = ?(ПоМестномуВремени И ЗначениеЗаполнено(Блокировка.КонецБлокировки), 
		МестноеВремя(Блокировка.КонецБлокировки), Блокировка.КонецБлокировки);
	Результат.Сообщение = Блокировка.СообщениеБлокировки;
	Результат.Эксклюзивная = Блокировка.Эксклюзивная;
	Результат.Установлена = Истина;
	Если ЗначениеЗаполнено(Блокировка.КонецБлокировки) И ТекущаяДатаСеанса() > Блокировка.КонецБлокировки Тогда
		Результат.Установлена = Ложь;
	КонецЕсли;
	Возврат Результат;
	
КонецФункции

#КонецОбласти

#Область СлужебныйПрограммныйИнтерфейс

Функция ПодсистемаИспользуется() Экспорт
	
	// См. также функцию СоединенияИБКлиент.ПодсистемаИспользуется
	Возврат Не ОбщегоНазначения.РазделениеВключено();
	
КонецФункции

// Возвращает текстовую строку со списком активных соединений ИБ.
// Названия соединений разделены символом переноса строки.
//
// Параметры:
//  Сообщение - Строка - передаваемая строка.
//
// Возвращаемое значение:
//   Строка - названия соединений.
//
Функция СообщениеОНеотключенныхСеансах() Экспорт
	
	Сообщение = НСтр("ru = 'Не удалось отключить сеансы:';
					|en = 'Cannot close sessions:'");
	НомерТекущегоСеанса = НомерСеансаИнформационнойБазы();
	Для Каждого Сеанс Из ПолучитьСеансыИнформационнойБазы() Цикл
		Если Сеанс.НомерСеанса <> НомерТекущегоСеанса Тогда
			Сообщение = Сообщение + Символы.ПС + "• " + Сеанс;
		КонецЕсли;
	КонецЦикла;
	
	Возврат Сообщение;
	
КонецФункции

// Получить число активных сеансов ИБ.
//
// Параметры:
//   УчитыватьКонсоль - Булево - если Ложь, то исключить сеансы консоли кластера серверов.
//                               Сеансы консоли кластера серверов не препятствуют выполнению 
//                               административных операций (установке монопольного режима и т.п.).
//
// Возвращаемое значение:
//   Число - количество активных сеансов ИБ.
//
Функция КоличествоСеансовИнформационнойБазы(УчитыватьКонсоль = Истина, УчитыватьФоновыеЗадания = Истина) Экспорт
	
	СеансыИБ = ПолучитьСеансыИнформационнойБазы();
	Если УчитыватьКонсоль И УчитыватьФоновыеЗадания Тогда
		Возврат СеансыИБ.Количество();
	КонецЕсли;
	
	Результат = 0;
	
	Для Каждого СеансИБ Из СеансыИБ Цикл
		
		Если Не УчитыватьКонсоль И СеансИБ.ИмяПриложения = "SrvrConsole"
			Или Не УчитыватьФоновыеЗадания И СеансИБ.ИмяПриложения = "BackgroundJob" Тогда
			Продолжить;
		КонецЕсли;
		
		Результат = Результат + 1;
		
	КонецЦикла;
	
	Возврат Результат;
	
КонецФункции

// Определяет количество сеансов информационной базы и наличие сеансов,
// которые не могут быть отключены принудительно. Формирует текст сообщения
// об ошибке.
//
Функция ИнформацияОБлокирующихСеансах(ТекстСообщения = "") Экспорт
	
	ИнформацияОБлокирующихСеансах = Новый Структура;
	
	НомерТекущегоСеанса = НомерСеансаИнформационнойБазы();
	СеансыИнформационнойБазы = ПолучитьСеансыИнформационнойБазы();
	
	ИмеютсяБлокирующиеСеансы = Ложь;
	Если ОбщегоНазначения.ИнформационнаяБазаФайловая() Тогда
		ИменаАктивныхСеансов = "";
		Для Каждого Сеанс Из СеансыИнформационнойБазы Цикл
			Если Сеанс.НомерСеанса <> НомерТекущегоСеанса
				И Сеанс.ИмяПриложения <> "1CV8"
				И Сеанс.ИмяПриложения <> "1CV8C"
				И Сеанс.ИмяПриложения <> "WebClient" Тогда
				ИменаАктивныхСеансов = ИменаАктивныхСеансов + Символы.ПС + "• " + Сеанс;
				ИмеютсяБлокирующиеСеансы = Истина;
			КонецЕсли;
		КонецЦикла;
	КонецЕсли;
	
	ИнформацияОБлокирующихСеансах.Вставить("ИмеютсяБлокирующиеСеансы", ИмеютсяБлокирующиеСеансы);
	ИнформацияОБлокирующихСеансах.Вставить("КоличествоСеансов", СеансыИнформационнойБазы.Количество());
	
	Если ИмеютсяБлокирующиеСеансы Тогда
		Сообщение = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			НСтр("ru = 'Имеются активные сеансы работы с программой,
			|которые не могут быть завершены принудительно:
			|%1
			|%2';
			|en = 'There are active sessions
			|that cannot be closed:
			|%1
			|%2'"),
			ИменаАктивныхСеансов, ТекстСообщения);
		ИнформацияОБлокирующихСеансах.Вставить("ТекстСообщения", Сообщение);
		
	КонецЕсли;
	
	Возврат ИнформацияОБлокирующихСеансах;
	
КонецФункции

////////////////////////////////////////////////////////////////////////////////
// Обработчики событий подсистем конфигурации.

// См. РаботаВМоделиСервисаПереопределяемый.ПриЗаполненииТаблицыПараметровИБ.
Процедура ПриЗаполненииТаблицыПараметровИБ(Знач ТаблицаПараметров) Экспорт
	
	Если Не ПодсистемаИспользуется() Тогда
		Возврат;
	КонецЕсли;
	
	Если ОбщегоНазначения.ПодсистемаСуществует("ТехнологияСервиса.БазоваяФункциональность") Тогда
		МодульРаботаВМоделиСервиса = ОбщегоНазначения.ОбщийМодуль("РаботаВМоделиСервиса");
		МодульРаботаВМоделиСервиса.ДобавитьКонстантуВТаблицуПараметровИБ(ТаблицаПараметров, "СообщениеБлокировкиПриОбновленииКонфигурации");
	КонецЕсли;
	
КонецПроцедуры

// См. ОбщегоНазначенияПереопределяемый.ПриДобавленииПараметровРаботыКлиентаПриЗапуске.
Процедура ПриДобавленииПараметровРаботыКлиентаПриЗапуске(Параметры) Экспорт
	
	Если Не ПодсистемаИспользуется() Тогда
		Возврат;
	КонецЕсли;
	
	ПараметрыБлокировки = ТекущиеПараметрыБлокировкиСоединений();
	Параметры.Вставить("ПараметрыБлокировкиСеансов", Новый ФиксированнаяСтруктура(ПараметрыБлокировкиСеансовРасширенные(Ложь, ПараметрыБлокировки)));
	
	Если Не ПараметрыБлокировки.УстановленаБлокировкаСоединений
		Или Не ОбщегоНазначения.РазделениеВключено()
		Или Не ОбщегоНазначения.ДоступноИспользованиеРазделенныхДанных() Тогда
		Возврат;
	КонецЕсли;
	
	// Дальнейший код актуален только для области данных с установленной блокировкой.
	Если ОбновлениеИнформационнойБазы.ВыполняетсяОбновлениеИнформационнойБазы() 
		И Пользователи.ЭтоПолноправныйПользователь() Тогда
		// Администратор приложения может входить, несмотря на незавершенное обновление области (и блокировку области данных).
		// При этом он инициирует обновление области.
		Возврат; 
	КонецЕсли;
	
	ТекущийРежим = ПараметрыБлокировки.ТекущийРежимОбластиДанных;
	
	Если ЗначениеЗаполнено(ТекущийРежим.Конец) Тогда
		Если ЗначениеЗаполнено(ТекущийРежим.Сообщение) Тогда
			ТекстСообщения = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
				НСтр("ru = 'Администратором приложения установлена блокировка работы пользователей на период с %1 по %2 по причине:
					|%3.';
					|en = 'The application administrator locked the application for the period from %1 to %2. Reason:
					|%3.'"), ТекущийРежим.Начало, ТекущийРежим.Конец, ТекущийРежим.Сообщение);
		Иначе
			ТекстСообщения = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
				НСтр("ru = 'Администратором приложения установлена блокировка работы пользователей на период с %1 по %2 для проведения регламентных работ.';
					|en = 'The application administrator locked the application for the period from %1 to %2 for scheduled maintenance.'"), 
				ТекущийРежим.Начало, ТекущийРежим.Конец);
		КонецЕсли;		
	Иначе
		Если ЗначениеЗаполнено(ТекущийРежим.Сообщение) Тогда
			ТекстСообщения = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
				НСтр("ru = 'Администратором приложения установлена блокировка работы пользователей на период с %1 по причине:
					|%2.';
					|en = 'The application administrator locked the application at %1. Reason:
					|%2.'"), ТекущийРежим.Начало, ТекущийРежим.Сообщение);
		Иначе
			ТекстСообщения = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
				НСтр("ru = 'Администратором приложения установлена блокировка работы пользователей на период с %1 для проведения регламентных работ.';
					|en = 'The application administrator locked the application at %1 due for scheduled maintenance.'"), 
				ТекущийРежим.Начало);
		КонецЕсли;		
	КонецЕсли;
	Параметры.Вставить("СеансыОбластиДанныхЗаблокированы", ТекстСообщения + Символы.ПС + Символы.ПС + НСтр("ru = 'Приложение временно недоступно.';
																											|en = 'The application is temporarily unavailable.'"));
	ТекстСообщенияДляВхода = "";
	Если Пользователи.ЭтоПолноправныйПользователь() Тогда
		ТекстСообщенияДляВхода = ТекстСообщения + Символы.ПС + Символы.ПС + НСтр("ru = 'Войти в заблокированное приложение?';
																				|en = 'Do you want to sign in to the locked application?'");
	КонецЕсли;
	Параметры.Вставить("ПредложениеВойти", ТекстСообщенияДляВхода);
	Если (Пользователи.ЭтоПолноправныйПользователь() И Не ТекущийРежим.Эксклюзивная) 
		Или Пользователи.ЭтоПолноправныйПользователь(, Истина) Тогда
		
		Параметры.Вставить("ВозможноСнятьБлокировку", Истина);
	Иначе
		Параметры.Вставить("ВозможноСнятьБлокировку", Ложь);
	КонецЕсли;
	
КонецПроцедуры

// См. ОбщегоНазначенияПереопределяемый.ПриДобавленииПараметровРаботыКлиента.
Процедура ПриДобавленииПараметровРаботыКлиента(Параметры) Экспорт
	
	Если Не ПодсистемаИспользуется() Тогда
		Возврат;
	КонецЕсли;
	
	Параметры.Вставить("ПараметрыБлокировкиСеансов", Новый ФиксированнаяСтруктура(ПараметрыБлокировкиСеансов()));
	
КонецПроцедуры

// См. ВыгрузкаЗагрузкаДанныхПереопределяемый.ПриЗаполненииТиповИсключаемыхИзВыгрузкиЗагрузки.
Процедура ПриЗаполненииТиповИсключаемыхИзВыгрузкиЗагрузки(Типы) Экспорт
	
	Типы.Добавить(Метаданные.РегистрыСведений.БлокировкиСеансовОбластейДанных);
	
КонецПроцедуры

// Параметры:
//   ТекущиеДела - см. ТекущиеДелаСервер.ТекущиеДела.
//
Процедура ПриЗаполненииСпискаТекущихДел(ТекущиеДела) Экспорт
	
	Если Не ПодсистемаИспользуется() Тогда
		Возврат;
	КонецЕсли;
	
	МодульТекущиеДелаСервер = ОбщегоНазначения.ОбщийМодуль("ТекущиеДелаСервер");
	Если Не ПравоДоступа("АдминистрированиеДанных", Метаданные)
		Или МодульТекущиеДелаСервер.ДелоОтключено("БлокировкаСеансов") Тогда
		Возврат;
	КонецЕсли;
	
	// Процедура вызывается только при наличии подсистемы "Текущие дела", поэтому здесь
	// не делается проверка существования подсистемы.
	Разделы = МодульТекущиеДелаСервер.РазделыДляОбъекта(Метаданные.Обработки.БлокировкаРаботыПользователей.ПолноеИмя());
	
	ПараметрыБлокировки = ПараметрыБлокировкиСеансов(Ложь);
	ТекущаяДатаСеанса = ТекущаяДатаСеанса();
	
	Если ПараметрыБлокировки.Установлена Тогда
		Если ТекущаяДатаСеанса < ПараметрыБлокировки.Начало Тогда
			Если ПараметрыБлокировки.Конец <> Дата(1, 1, 1) Тогда
				Сообщение = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(НСтр("ru = 'Запланирована с %1 по %2';
																						|en = 'Scheduled from %1 to %2'"),
					Формат(ПараметрыБлокировки.Начало, "ДЛФ=DT"), Формат(ПараметрыБлокировки.Конец, "ДЛФ=DT"));
			Иначе
				Сообщение = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(НСтр("ru = 'Запланирована с %1';
																						|en = 'Scheduled from %1'"), Формат(ПараметрыБлокировки.Начало, "ДЛФ=DT"));
			КонецЕсли;
			Важность = Ложь;
		ИначеЕсли ПараметрыБлокировки.Конец <> Дата(1, 1, 1) И ТекущаяДатаСеанса > ПараметрыБлокировки.Конец И ПараметрыБлокировки.Начало <> Дата(1, 1, 1) Тогда
			Важность = Ложь;
			Сообщение = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(НСтр("ru = 'Не действует (истек срок %1)';
																					|en = 'Inactive (expired on %1)'"), Формат(ПараметрыБлокировки.Конец, "ДЛФ=DT"));
		Иначе
			Если ПараметрыБлокировки.Конец <> Дата(1, 1, 1) Тогда
				Сообщение = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(НСтр("ru = 'с %1 по %2';
																						|en = 'from %1 to %2'"),
					Формат(ПараметрыБлокировки.Начало, "ДЛФ=DT"), Формат(ПараметрыБлокировки.Конец, "ДЛФ=DT"));
			Иначе
				Сообщение = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(НСтр("ru = 'с %1';
																						|en = 'from %1'"), 
					Формат(ПараметрыБлокировки.Начало, "ДЛФ=DT"));
			КонецЕсли;
			Важность = Истина;
		КонецЕсли;
	Иначе
		Сообщение = НСтр("ru = 'Не действует';
						|en = 'Inactive'");
		Важность = Ложь;
	КонецЕсли;

	
	Для Каждого Раздел Из Разделы Цикл
		
		ИдентификаторДела = "БлокировкаСеансов" + СтрЗаменить(Раздел.ПолноеИмя(), ".", "");
		
		Дело = ТекущиеДела.Добавить();
		Дело.Идентификатор  = ИдентификаторДела;
		Дело.ЕстьДела       = ПараметрыБлокировки.Установлена;
		Дело.Представление  = НСтр("ru = 'Блокировка работы пользователей';
									|en = 'Deny user access'");
		Дело.Форма          = "Обработка.БлокировкаРаботыПользователей.Форма";
		Дело.Важное         = Важность;
		Дело.Владелец       = Раздел;
		
		Дело = ТекущиеДела.Добавить();
		Дело.Идентификатор  = "БлокировкаСеансовПодробности";
		Дело.ЕстьДела       = ПараметрыБлокировки.Установлена;
		Дело.Представление  = Сообщение;
		Дело.Владелец       = ИдентификаторДела; 
		
	КонецЦикла;
	
КонецПроцедуры

// См. ОбщегоНазначенияПереопределяемый.ПриДобавленииСерверныхОповещений
Процедура ПриДобавленииСерверныхОповещений(Оповещения) Экспорт
	
	Если Не ПодсистемаИспользуется() Тогда
		Возврат;
	КонецЕсли;
	
	Оповещение = СерверныеОповещения.НовоеСерверноеОповещение(
		"СтандартныеПодсистемы.ЗавершениеРаботыПользователей.БлокировкаСеансов");
	Оповещение.ИмяМодуляОтправки  = "СоединенияИБ";
	Оповещение.ИмяМодуляПолучения = "СоединенияИБКлиент";
	Оповещение.ПериодПроверки = 300;
	
	Оповещения.Вставить(Оповещение.Имя, Оповещение);
	
КонецПроцедуры

// См. СтандартныеПодсистемыСервер.ПриОтправкеСерверногоОповещения
Процедура ПриОтправкеСерверногоОповещения(ИмяОповещения, ВариантыПараметров) Экспорт
	
	ОтправитьСерверноеОповещениеОбУстановкеБлокировки(Истина);
	
КонецПроцедуры

// См. ОбщегоНазначенияПереопределяемый.ПриПериодическомПолученииДанныхКлиентаНаСервере
Процедура ПриПериодическомПолученииДанныхКлиентаНаСервере(Параметры, Результаты) Экспорт
	
	Если Не ПодсистемаИспользуется() Тогда
		Возврат;
	КонецЕсли;
	
	ИмяПараметра = "СтандартныеПодсистемы.ЗавершениеРаботыПользователей.БлокировкаСеансов";
	ПараметрыБлокировкиСеансов = ПараметрыБлокировкиСеансовКогдаУстановлена();
	
	Если ПараметрыБлокировкиСеансов <> Неопределено
	   И ПараметрыБлокировкиСеансов.Установлена Тогда
		
		Результаты.Вставить(ИмяПараметра, ПараметрыБлокировкиСеансов);
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

Процедура ОтправитьСерверноеОповещениеОбУстановкеБлокировки(ПриОтправкеСерверногоОповещения = Ложь) Экспорт
	
	Попытка
		ПараметрыБлокировкиСеансов = ПараметрыБлокировкиСеансовКогдаУстановлена();
		Если ПараметрыБлокировкиСеансов = Неопределено Тогда
			ПараметрыБлокировкиСеансов = Новый Структура("Установлена", Ложь);
		КонецЕсли;
		
		Если ПараметрыБлокировкиСеансов.Установлена
		 Или Не ПриОтправкеСерверногоОповещения Тогда
			
			СерверныеОповещения.ОтправитьСерверноеОповещение(
				"СтандартныеПодсистемы.ЗавершениеРаботыПользователей.БлокировкаСеансов",
				ПараметрыБлокировкиСеансов, Неопределено, Не ПриОтправкеСерверногоОповещения);
		КонецЕсли;
	Исключение
		Если ПриОтправкеСерверногоОповещения Тогда
			ВызватьИсключение;
		КонецЕсли;
		ЗаписьЖурналаРегистрации(СобытиеЖурналаРегистрации(),
			УровеньЖурналаРегистрации.Ошибка,,,
			ОбработкаОшибок.ПодробноеПредставлениеОшибки(ИнформацияОбОшибке()));
	КонецПопытки;
	
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// Прочее.

// Возвращает текст сообщения блокировки сеансов.
//
// Параметры:
//  Сообщение - Строка - сообщение для блокировки.
//  КодРазрешения - Строка - код разрешения для входа в информационную базу.
//
// Возвращаемое значение:
//   Строка - сообщение блокировки.
//
Функция СформироватьСообщениеБлокировки(Знач Сообщение, Знач КодРазрешения) Экспорт
	
	ПараметрыАдминистрирования = СтандартныеПодсистемыСервер.ПараметрыАдминистрирования();
	ПризнакФайловогоРежима = Ложь;
	ПутьКИБ = СоединенияИБКлиентСервер.ПутьКИнформационнойБазе(ПризнакФайловогоРежима, ПараметрыАдминистрирования.ПортКластера);
	СтрокаПутиКИнформационнойБазе = ?(ПризнакФайловогоРежима = Истина, "/F", "/S") + ПутьКИБ;
	ТекстСообщения = "";
	Если НЕ ПустаяСтрока(Сообщение) Тогда
		ТекстСообщения = Сообщение + Символы.ПС + Символы.ПС;
	КонецЕсли;
	
	ИмяПараметра = "РазрешитьРаботуПользователей";
	Если ОбщегоНазначения.РазделениеВключено() И ОбщегоНазначения.ДоступноИспользованиеРазделенныхДанных() Тогда
		ТекстСообщения = ТекстСообщения + НСтр("ru = '%1
			|Для разрешения работы пользователей можно открыть приложение с параметром %2. Например:
			|http://<веб-адрес сервера>/?C=%2';
			|en = '%1
			|To allow user access, you can open the application with parameter %2. For example:
			|http://<server web address>/?C=%2'");
		ТекстСообщения = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(ТекстСообщения, 
			СоединенияИБКлиентСервер.ТекстДляАдминистратора(), ИмяПараметра);
	Иначе
		ТекстСообщения = ТекстСообщения + НСтр("ru = '%1
			|Для того чтобы разрешить работу пользователей, воспользуйтесь консолью кластера серверов или запустите ""1С:Предприятие"" с параметрами:
			|ENTERPRISE %2 /C%3 /UC%4';
			|en = '%1
			|To allow user access, use the server cluster console or run 1C:Enterprise with the following parameters:
			|ENTERPRISE %2 /C%3 /UC%4'");
		ТекстСообщения = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(ТекстСообщения, СоединенияИБКлиентСервер.ТекстДляАдминистратора(),
			СтрокаПутиКИнформационнойБазе, ИмяПараметра, НСтр("ru = '<код разрешения>';
																|en = '<access code>'"));
	КонецЕсли;
	
	Возврат ТекстСообщения;
	
КонецФункции

// Возвращает установлена ли блокировка соединений на конкретную дату.
//
// Параметры:
//  ТекущийРежим - БлокировкаСеансов - блокировка сеансов.
//  ТекущаяДата - Дата - дата, на которую необходимо проверить.
//
// Возвращаемое значение:
//  Булево - Истина, если установлена.
//
Функция УстановленаБлокировкаСоединенийНаДату(ТекущийРежим, ТекущаяДата)
	
	Возврат (ТекущийРежим.Установлена И ТекущийРежим.Начало <= ТекущаяДата 
		И (Не ЗначениеЗаполнено(ТекущийРежим.Конец) Или ТекущаяДата <= ТекущийРежим.Конец));
	
КонецФункции

// См. описание в функции ПараметрыБлокировкиСеансов.
//
// Параметры:
//    ПолучитьКоличествоСеансов - Булево
//    ПараметрыБлокировки - см. ТекущиеПараметрыБлокировкиСоединений
//
Функция ПараметрыБлокировкиСеансовРасширенные(Знач ПолучитьКоличествоСеансов, ПараметрыБлокировки)
	
	Если ПараметрыБлокировки.УстановленаБлокировкаСоединенийИБНаДату Тогда
		ТекущийРежим = ПараметрыБлокировки.ТекущийРежимИБ;
	ИначеЕсли ПараметрыБлокировки.УстановленаБлокировкаСоединенийОбластиДанныхНаДату Тогда
		ТекущийРежим = ПараметрыБлокировки.ТекущийРежимОбластиДанных;
	ИначеЕсли ПараметрыБлокировки.ТекущийРежимИБ.Установлена Тогда
		ТекущийРежим = ПараметрыБлокировки.ТекущийРежимИБ;
	Иначе
		ТекущийРежим = ПараметрыБлокировки.ТекущийРежимОбластиДанных;
	КонецЕсли;
	
	УстановитьПривилегированныйРежим(Истина);
	
	Результат = Новый Структура;
	Результат.Вставить("Установлена", ТекущийРежим.Установлена);
	Результат.Вставить("Начало", ТекущийРежим.Начало);
	Результат.Вставить("Конец", ТекущийРежим.Конец);
	Результат.Вставить("Сообщение", ТекущийРежим.Сообщение);
	Результат.Вставить("ИнтервалОжиданияЗавершенияРаботыПользователей", 15 * 60);
	Результат.Вставить("КоличествоСеансов", ?(ПолучитьКоличествоСеансов, КоличествоСеансовИнформационнойБазы(), 0));
	Результат.Вставить("ТекущаяДатаСеанса", ПараметрыБлокировки.ТекущаяДата);
	Результат.Вставить("ПерезапуститьПриЗавершении", Истина);
	
	СоединенияИБПереопределяемый.ПриОпределенииПараметровБлокировкиСеансов(Результат);
	
	Возврат Результат;
	
КонецФункции

// Параметры:
//   ВернутьНеопределеноКогдаНеУстановлена - Булево
// 
// Возвращаемое значение:
//   Структура:
//   * УстановленаБлокировкаСоединенийИБНаДату - Булево
//   * ТекущийРежимОбластиДанных - см. НовыеПараметрыБлокировкиСоединений
//   * ТекущийРежимИБ - БлокировкаСеансов
//   * ТекущаяДата - Дата
//
Функция ТекущиеПараметрыБлокировкиСоединений(ВернутьНеопределеноКогдаНеУстановлена = Ложь)
	
	ТекущаяДата = ТекущаяДата(); // АПК:143 ТекущаяДатаСеанса не используется, т.к. блокировка в часовом поясе сервера.
	
	УстановитьПривилегированныйРежим(Истина);
	ТекущийРежимИБ = ПолучитьБлокировкуСеансов();
	Если ВернутьНеопределеноКогдаНеУстановлена
	   И Не ТекущийРежимИБ.Установлена
	   И Не ОбщегоНазначения.РазделениеВключено() Тогда
		Возврат Неопределено;
	КонецЕсли;
	ТекущийРежимОбластиДанных = ПолучитьБлокировкуСеансовОбластиДанных();
	УстановитьПривилегированныйРежим(Ложь);
	
	УстановленаБлокировкаИБНаДату = УстановленаБлокировкаСоединенийНаДату(ТекущийРежимИБ, ТекущаяДата);
	УстановленаБлокировкаОбластиНаДату = УстановленаБлокировкаСоединенийНаДату(ТекущийРежимОбластиДанных, ТекущаяДата);
	УстановленаБлокировкаСоединений = УстановленаБлокировкаИБНаДату Или УстановленаБлокировкаОбластиНаДату;
	
	Параметры = Новый Структура;
	Параметры.Вставить("ТекущаяДата", ТекущаяДата);
	Параметры.Вставить("ТекущийРежимИБ", ТекущийРежимИБ);
	Параметры.Вставить("ТекущийРежимОбластиДанных", ТекущийРежимОбластиДанных);
	Параметры.Вставить("УстановленаБлокировкаСоединенийИБНаДату", УстановленаБлокировкаИБНаДату);
	Параметры.Вставить("УстановленаБлокировкаСоединенийОбластиДанныхНаДату", УстановленаБлокировкаОбластиНаДату);
	Параметры.Вставить("УстановленаБлокировкаСоединений", УстановленаБлокировкаСоединений);
	
	Возврат Параметры;
	
КонецФункции

// Возвращаемое значение:
//   см. ПараметрыБлокировкиСеансов
//
Функция ПараметрыБлокировкиСеансовКогдаУстановлена()
	
	ПараметрыБлокировки = ТекущиеПараметрыБлокировкиСоединений(Истина);
	Если ПараметрыБлокировки = Неопределено Тогда
		Возврат Неопределено;
	КонецЕсли;
	
	Результат = ПараметрыБлокировкиСеансовРасширенные(Ложь, ПараметрыБлокировки);
	Если ПараметрыБлокировки.УстановленаБлокировкаСоединенийИБНаДату Тогда
		Результат.Вставить("Параметр", ПараметрыБлокировки.ТекущийРежимИБ.Параметр);
	КонецЕсли;
	
	Возврат Результат;
	
КонецФункции

// Возвращает строковую константу для формирования сообщений журнала регистрации.
//
// Возвращаемое значение:
//   Строка - наименование события для журнала регистрации.
//
Функция СобытиеЖурналаРегистрации() Экспорт
	
	Возврат НСтр("ru = 'Завершение работы пользователей';
				|en = 'User sessions'", ОбщегоНазначения.КодОсновногоЯзыка());
	
КонецФункции

#КонецОбласти
