﻿///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2021, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область ПрограммныйИнтерфейс

#Область ДляВызоваИзДругихПодсистем

// СтандартныеПодсистемы.ГрупповоеИзменениеОбъектов

// Возвращает реквизиты объекта, которые разрешается редактировать
// с помощью обработки группового изменения реквизитов.
//
// Возвращаемое значение:
//  Массив из Строка
//
Функция РеквизитыРедактируемыеВГрупповойОбработке() Экспорт
	
	РедактируемыеРеквизиты = Новый Массив;
	
	РедактируемыеРеквизиты.Добавить("МногострочноеПолеВвода");
	РедактируемыеРеквизиты.Добавить("ЗаголовокФормыЗначения");
	РедактируемыеРеквизиты.Добавить("ЗаголовокФормыВыбораЗначения");
	РедактируемыеРеквизиты.Добавить("ФорматСвойства");
	РедактируемыеРеквизиты.Добавить("Комментарий");
	РедактируемыеРеквизиты.Добавить("Подсказка");
	
	Возврат РедактируемыеРеквизиты;
	
КонецФункции

// Конец СтандартныеПодсистемы.ГрупповоеИзменениеОбъектов

// СтандартныеПодсистемы.ЗапретРедактированияРеквизитовОбъектов

// Возвращаемое значение:
//   см. ЗапретРедактированияРеквизитовОбъектовПереопределяемый.ПриОпределенииЗаблокированныхРеквизитов.ЗаблокированныеРеквизиты.
//
Функция ПолучитьБлокируемыеРеквизитыОбъекта() Экспорт
	
	Результат = Новый Массив;
	
	Результат.Добавить("ТипЗначения");
	Результат.Добавить("Имя");
	Результат.Добавить("ИдентификаторДляФормул");
	
	Возврат Результат;
	
КонецФункции

// Конец СтандартныеПодсистемы.ЗапретРедактированияРеквизитовОбъектов

#КонецОбласти

#КонецОбласти

#КонецЕсли

#Область ОбработчикиСобытий

#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

Процедура ОбработкаПолученияДанныхВыбора(ДанныеВыбора, Параметры, СтандартнаяОбработка)
	
	Если Параметры.Свойство("ЭтоВыборЗначенияДоступа") Тогда
		Параметры.Отбор.Вставить("ЭтоДополнительноеСведение", Истина);
	КонецЕсли;
	
КонецПроцедуры

#КонецЕсли

Процедура ОбработкаПолученияПолейПредставления(Поля, СтандартнаяОбработка)
	Поля.Добавить("НаборСвойств");
	Поля.Добавить("Заголовок");
	Поля.Добавить("Ссылка");
	
	СтандартнаяОбработка = Ложь;
КонецПроцедуры

Процедура ОбработкаПолученияПредставления(Данные, Представление, СтандартнаяОбработка)
	
#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда
	Если ОбщегоНазначения.ПодсистемаСуществует("СтандартныеПодсистемы.Мультиязычность") Тогда
		МодульМультиязычностьКлиентСервер = ОбщегоНазначения.ОбщийМодуль("МультиязычностьКлиентСервер");
		МодульМультиязычностьКлиентСервер.ОбработкаПолученияПредставления(Данные, Представление, СтандартнаяОбработка, "Заголовок");
	КонецЕсли;
#Иначе
	Если ОбщегоНазначенияКлиент.ПодсистемаСуществует("СтандартныеПодсистемы.Мультиязычность") Тогда
		МодульМультиязычностьКлиентСервер = ОбщегоНазначенияКлиент.ОбщийМодуль("МультиязычностьКлиентСервер");
		МодульМультиязычностьКлиентСервер.ОбработкаПолученияПредставления(Данные, Представление, СтандартнаяОбработка, "Заголовок");
	КонецЕсли;
#КонецЕсли
	
	Если Не ЗначениеЗаполнено(Представление) Тогда
		Представление = Данные.Заголовок;
	КонецЕсли;
	
	Если ЗначениеЗаполнено(Данные.НаборСвойств) Тогда
		Представление = Представление + " (" + Строка(Данные.НаборСвойств) + ")";
	КонецЕсли;
	СтандартнаяОбработка = Ложь;
КонецПроцедуры

#КонецОбласти

#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область СлужебныеПроцедурыИФункции

#Область УникальностьИдентификатораДляФормул

// Проверяет уникальность идентификатора, а также соответствие идентификатора правилам написания
// 
// Параметры:
//   ИдентификаторДляФормул - Строка - идентификатор для формул.
//   Ссылка - ПланВидовХарактеристикСсылка.ДополнительныеРеквизитыИСведения - ссылка на текущий объект.
//   Отказ - Булево - флаг отказа при наличии ошибки.
//
Процедура ПроверитьУникальностьИдентификатора(ИдентификаторДляФормул, Ссылка, Отказ) Экспорт
	
	Если ЗначениеЗаполнено(ИдентификаторДляФормул) Тогда
		
		ИдентификаторПоПравилам = Истина;
		ПроверочныйИдентификатор = ИдентификаторДляФормул(ИдентификаторДляФормул);
		Если НЕ ВРег(ПроверочныйИдентификатор) = ВРег(ИдентификаторДляФормул) Тогда
			ИдентификаторПоПравилам = Ложь;
			
			ТекстОшибки = НСтр("ru = 'Идентификатор ""%1"" не соответствует правилам именования переменных.
										|Идентификатор не должен содержать пробелов и специальных символов.'");
			ОбщегоНазначения.СообщитьПользователю(
				СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(ТекстОшибки, ИдентификаторДляФормул),,
				"ИдентификаторДляФормул",, Отказ);
				
			КодЯзыка = ОбщегоНазначения.КодОсновногоЯзыка();
			ИмяСобытия = НСтр("ru = 'Запись дополнительного реквизита (сведения)'", КодЯзыка);
			ТекстОшибки = НСтр("ru = 'Идентификатор ""%1"" не соответствует правилам именования переменных.
									|Идентификатор не должен содержать пробелов и специальных символов.'", КодЯзыка);
			ТекстОшибки = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(ТекстОшибки,
				ИдентификаторДляФормул);
			ЗаписьЖурналаРегистрации(ИмяСобытия,
					УровеньЖурналаРегистрации.Ошибка,
					Ссылка.Метаданные(),
					Ссылка,
					ТекстОшибки);
		КонецЕсли;
		
		Если ИдентификаторПоПравилам Тогда
			Если НЕ ИдентификаторДляФормулУникален(ИдентификаторДляФормул, Ссылка) Тогда
				
				Отказ = Истина;
				
				ТекстОшибки = НСтр("ru = 'Идентификатор для формул ""%1"" не уникален'");
				ТекстОшибки = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(ТекстОшибки,
					ИдентификаторДляФормул);
				ОбщегоНазначения.СообщитьПользователю(ТекстОшибки,, "ИдентификаторДляФормул");
				
				КодЯзыка = ОбщегоНазначения.КодОсновногоЯзыка();
				ТекстОшибки = НСтр("ru = 'Идентификатор для формул ""%1"" не уникален'", КодЯзыка);
				ТекстОшибки = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(ТекстОшибки,
					ИдентификаторДляФормул);
				ИмяСобытия = НСтр("ru = 'Запись дополнительного реквизита (сведения)'", КодЯзыка);
				ЗаписьЖурналаРегистрации(ИмяСобытия,
					УровеньЖурналаРегистрации.Ошибка,
					Ссылка.Метаданные(),
					Ссылка,
					ТекстОшибки);
			КонецЕсли;
		КонецЕсли;
		
	Иначе
		
		ТекстОшибки = НСтр("ru = 'Идентификатор для формул не заполнен'");
		ОбщегоНазначения.СообщитьПользователю(
			СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(ТекстОшибки, ИдентификаторДляФормул),,
			"ИдентификаторДляФормул",, Отказ);
			
		КодЯзыка = ОбщегоНазначения.КодОсновногоЯзыка();
		ИмяСобытия = НСтр("ru = 'Запись дополнительного реквизита (сведения)'", КодЯзыка);
		ТекстОшибки = НСтр("ru = 'Идентификатор для формул не заполнен'", КодЯзыка);
		ЗаписьЖурналаРегистрации(ИмяСобытия,
			УровеньЖурналаРегистрации.Ошибка,
			Ссылка.Метаданные(),
			Ссылка,
			ТекстОшибки);
			
	КонецЕсли;
	
КонецПроцедуры

// Возвращает уникальный идентификатора для формул (после проверки на уникальность)
// 
// Параметры:
//   ПредставлениеОбъекта - Строка - представление, из которого будет сформирован идентификатор для формул.
//   СсылкаНаТекущийОбъект - ПланВидовХарактеристикСсылка.ДополнительныеРеквизитыИСведения - ссылка на текущий элемент.
// Возвращаемое значение:
//   Строка - уникальное значение идентификатора для формул.
//
Функция УникальныйИдентификаторДляФормул(ПредставлениеОбъекта, СсылкаНаТекущийОбъект) Экспорт

	Идентификатор = ИдентификаторДляФормул(ПредставлениеОбъекта);
	Если ПустаяСтрока(Идентификатор) Тогда
		// Представление состоит и спецсимволов или цифр.
		Префикс = НСтр("ru = 'Идентификатор'");
		Идентификатор = ИдентификаторДляФормул(Префикс + ПредставлениеОбъекта);
	КонецЕсли;
	
	Запрос = Новый Запрос;
	Запрос.Текст =
	"ВЫБРАТЬ
	|	ДополнительныеРеквизитыИСведения.ИдентификаторДляФормул КАК ИдентификаторДляФормул
	|ИЗ
	|	ПланВидовХарактеристик.ДополнительныеРеквизитыИСведения КАК ДополнительныеРеквизитыИСведения
	|ГДЕ
	|	ДополнительныеРеквизитыИСведения.ИдентификаторДляФормул = &ИдентификаторДляФормул
	|	И ДополнительныеРеквизитыИСведения.Ссылка <> &СсылкаНаТекущийОбъект
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ДополнительныеРеквизитыИСведения.ИдентификаторДляФормул КАК ИдентификаторДляФормул
	|ИЗ
	|	ПланВидовХарактеристик.ДополнительныеРеквизитыИСведения КАК ДополнительныеРеквизитыИСведения
	|ГДЕ
	|	ДополнительныеРеквизитыИСведения.ИдентификаторДляФормул ПОДОБНО &ИдентификаторДляФормулПодобие
	|	И ДополнительныеРеквизитыИСведения.Ссылка <> &СсылкаНаТекущийОбъект";
	Запрос.УстановитьПараметр("СсылкаНаТекущийОбъект", СсылкаНаТекущийОбъект);
	Запрос.УстановитьПараметр("ИдентификаторДляФормул", Идентификатор);
	Запрос.УстановитьПараметр("ИдентификаторДляФормулПодобие", Идентификатор + "%");
	
	РезультатыЗапроса = Запрос.ВыполнитьПакет();
	УникальностьПоТочномуСоответствию = РезультатыЗапроса[0];
	Если НЕ УникальностьПоТочномуСоответствию.Пустой() Тогда
		// Есть элементы с данным идентификатором.
		ИспользованныеИдентификаторы = Новый Соответствие;
		ВыборкаПодобных = РезультатыЗапроса[1].Выбрать();
		Пока ВыборкаПодобных.Следующий() Цикл
			ИспользованныеИдентификаторы.Вставить(ВРЕГ(ВыборкаПодобных.ИдентификаторДляФормул), Истина);
		КонецЦикла;
		
		ДобавляемыйНомер = 1;
		ИдентификаторБезНомера = Идентификатор;
		Пока НЕ ИспользованныеИдентификаторы.Получить(ВРЕГ(Идентификатор)) = Неопределено Цикл
			ДобавляемыйНомер = ДобавляемыйНомер + 1;
			Идентификатор = ИдентификаторБезНомера + ДобавляемыйНомер;
		КонецЦикла;
	КонецЕсли;
	
	Возврат Идентификатор;
КонецФункции

Функция ИдентификаторДляФормулУникален(ПроверяемыйИдентификатор, СсылкаНаТекущийОбъект)
	
	Запрос = Новый Запрос;
	Запрос.Текст =
	"ВЫБРАТЬ
	|	ДополнительныеРеквизитыИСведения.ИдентификаторДляФормул КАК ИдентификаторДляФормул
	|ИЗ
	|	ПланВидовХарактеристик.ДополнительныеРеквизитыИСведения КАК ДополнительныеРеквизитыИСведения
	|ГДЕ
	|	ДополнительныеРеквизитыИСведения.ИдентификаторДляФормул = &ИдентификаторДляФормул
	|	И ДополнительныеРеквизитыИСведения.Ссылка <> &СсылкаНаТекущийОбъект";
	Запрос.УстановитьПараметр("ИдентификаторДляФормул", ПроверяемыйИдентификатор);
	Запрос.УстановитьПараметр("СсылкаНаТекущийОбъект", СсылкаНаТекущийОбъект);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	Возврат РезультатЗапроса.Пустой();
КонецФункции

// Вычисляет значение идентификатора из строки соответствии с правилами именования переменных.
// 
// Параметры:
//  СтрокаПредставления - Строка - наименование, строка из которой необходимо получить идентификатор. 
//
// Возвращаемое значение:
//  Строка - идентификатор, соответствующий правилам именования идентификаторов.
//
Функция ИдентификаторДляФормул(СтрокаПредставления) Экспорт
	
	СпецСимволы = СпецСимволы();
	
	Идентификатор = "";
	БылСпецСимвол = Ложь;
	
	Для НомСимвола = 1 По СтрДлина(СтрокаПредставления) Цикл
		
		Символ = Сред(СтрокаПредставления, НомСимвола, 1);
		
		Если СтрНайти(СпецСимволы, Символ) <> 0 Тогда
			БылСпецСимвол = Истина;
			Если Символ = "_" Тогда
				Идентификатор = Идентификатор + Символ;
			КонецЕсли;
		ИначеЕсли БылСпецСимвол
			ИЛИ НомСимвола = 1 Тогда
			БылСпецСимвол = Ложь;
			Идентификатор = Идентификатор + ВРег(Символ);
		Иначе
			Идентификатор = Идентификатор + Символ;
		КонецЕсли;
		
	КонецЦикла;
	
	Возврат Идентификатор;
	
КонецФункции

Функция СпецСимволы()
	Диапазоны = Новый Массив;
	Диапазоны.Добавить(Новый Структура("Мин, Макс", 0, 32));
	Диапазоны.Добавить(Новый Структура("Мин, Макс", 127, 191));
	
	СпецСимволы = " .,+,-,/,*,?,=,<,>,(,)%!@#$%&*""№:;{}[]?()\|/`~'^_";
	Для Каждого Диапазон Из Диапазоны Цикл
		Для КодСимвола = Диапазон.Мин По Диапазон.Макс Цикл
			СпецСимволы = СпецСимволы + Символ(КодСимвола);
		КонецЦикла;
	КонецЦикла;
	Возврат СпецСимволы;
КонецФункции

Функция ЗаголовокДляФормированияИдентификатора(Знач Заголовок, Знач Представления)
	Если ТекущийЯзык().КодЯзыка <> ОбщегоНазначения.КодОсновногоЯзыка() Тогда
		Отбор = Новый Структура();
		Отбор.Вставить("КодЯзыка", ОбщегоНазначения.КодОсновногоЯзыка());
		НайденныеСтроки = Представления.НайтиСтроки(Отбор);
		Если НайденныеСтроки.Количество() > 0 Тогда
			Заголовок = НайденныеСтроки[0].Заголовок;
		КонецЕсли;
	КонецЕсли;
	
	Возврат Заголовок;
КонецФункции

#КонецОбласти

// Изменяет настройку свойства с общего свойства или общего списка значений свойства
// на отдельное свойство с отдельным списком значений.
// 
// Параметры:
//  Параметры - Структура:
//     * Свойство - ПланВидовХарактеристикСсылка.ДополнительныеРеквизитыИСведения
//     * ТекущийНаборСвойств - СправочникСсылка.НаборыДополнительныхРеквизитовИСведений
//  АдресХранилища - Строка
//
Процедура ИзменитьНастройкуСвойства(Параметры, АдресХранилища) Экспорт
	
	Свойство            = Параметры.Свойство;
	ТекущийНаборСвойств = Параметры.ТекущийНаборСвойств;
	
	ОткрытьСвойство = Неопределено;
	Блокировка = Новый БлокировкаДанных;
	
	ЭлементБлокировки = Блокировка.Добавить("ПланВидовХарактеристик.ДополнительныеРеквизитыИСведения");
	ЭлементБлокировки.УстановитьЗначение("Ссылка", Свойство);
	
	ЭлементБлокировки = Блокировка.Добавить("Справочник.НаборыДополнительныхРеквизитовИСведений");
	ЭлементБлокировки.УстановитьЗначение("Ссылка", ТекущийНаборСвойств);
	
	ЭлементБлокировки = Блокировка.Добавить("Справочник.ЗначенияСвойствОбъектов");
	ЭлементБлокировки = Блокировка.Добавить("Справочник.ЗначенияСвойствОбъектовИерархия");
	
	НачатьТранзакцию();
	Попытка
		Блокировка.Заблокировать();
		
		СвойствоОбъект = Свойство.ПолучитьОбъект();
		
		Запрос = Новый Запрос;
		Если ЗначениеЗаполнено(СвойствоОбъект.ВладелецДополнительныхЗначений) Тогда
			Запрос.УстановитьПараметр("Владелец", СвойствоОбъект.ВладелецДополнительныхЗначений);
			СвойствоОбъект.ВладелецДополнительныхЗначений = Неопределено;
			СвойствоОбъект.Записать();
		Иначе
			Запрос.УстановитьПараметр("Владелец", Свойство);
			НовыйОбъект = СоздатьЭлемент();
			ЗаполнитьЗначенияСвойств(НовыйОбъект, СвойствоОбъект, , "Родитель, ИдентификаторДляФормул");
			
			Отбор = Новый Структура;
			Отбор.Вставить("НаборСвойств", ТекущийНаборСвойств);
			ЗависимостиНабора = СвойствоОбъект.ЗависимостиДополнительныхРеквизитов.НайтиСтроки(Отбор);
			Для Каждого Зависимость Из ЗависимостиНабора Цикл
				ЗаполнитьЗначенияСвойств(НовыйОбъект.ЗависимостиДополнительныхРеквизитов.Добавить(), Зависимость);
			КонецЦикла;
			
			СвойствоОбъект = НовыйОбъект;
			Если ЗначениеЗаполнено(СвойствоОбъект.Имя) Тогда
				ИмяЧастями = СтрРазделить(СвойствоОбъект.Имя, "_");
				Имя = ИмяЧастями[0];
				
				УИД = Новый УникальныйИдентификатор();
				СтрокаУИД = СтрЗаменить(Строка(УИД), "-", "");
				СвойствоОбъект.Имя = Имя + "_" + СтрокаУИД;
			КонецЕсли;
			СвойствоОбъект.НаборСвойств = ТекущийНаборСвойств;
			СвойствоОбъект.Записать();
			
			НаборСвойствОбъект = ТекущийНаборСвойств.ПолучитьОбъект();
			Если СвойствоОбъект.ЭтоДополнительноеСведение Тогда
				НайденнаяСтрока = НаборСвойствОбъект.ДополнительныеСведения.Найти(Свойство, "Свойство");
				Если НайденнаяСтрока = Неопределено Тогда
					НаборСвойствОбъект.ДополнительныеСведения.Добавить().Свойство = СвойствоОбъект.Ссылка;
				Иначе
					НайденнаяСтрока.Свойство = СвойствоОбъект.Ссылка;
					НайденнаяСтрока.ПометкаУдаления = Ложь;
				КонецЕсли;
			Иначе
				НайденнаяСтрока = НаборСвойствОбъект.ДополнительныеРеквизиты.Найти(Свойство, "Свойство");
				Если НайденнаяСтрока = Неопределено Тогда
					НаборСвойствОбъект.ДополнительныеРеквизиты.Добавить().Свойство = СвойствоОбъект.Ссылка;
				Иначе
					НайденнаяСтрока.Свойство = СвойствоОбъект.Ссылка;
					НайденнаяСтрока.ПометкаУдаления = Ложь;
				КонецЕсли;
			КонецЕсли;
			НаборСвойствОбъект.Записать();
		КонецЕсли;
		
		ОткрытьСвойство = СвойствоОбъект.Ссылка;
		
		МетаданныеВладельца = УправлениеСвойствамиСлужебный.МетаданныеВладельцаЗначенийСвойствНабора(
			ТекущийНаборСвойств, Ложь);
		
		Если МетаданныеВладельца = Неопределено Тогда
			ВызватьИсключение СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
				НСтр("ru = 'Ошибка при изменении настройки свойства %1.
				           |Набор свойств %2 не связан ни с одним владельцем значений свойств.'"),
				Свойство,
				ТекущийНаборСвойств);
		КонецЕсли;
		
		ПолноеИмяВладельца = МетаданныеВладельца.ПолноеИмя();
		СоответствиеСсылок = Новый Соответствие;
		
		ЕстьДополнительныеЗначения = УправлениеСвойствамиСлужебный.ТипЗначенияСодержитЗначенияСвойств(
			СвойствоОбъект.ТипЗначения);
		
		Если ЕстьДополнительныеЗначения Тогда
			
			Если СвойствоОбъект.ТипЗначения.СодержитТип(Тип("СправочникСсылка.ЗначенияСвойствОбъектов")) Тогда
				ИмяСправочника = "ЗначенияСвойствОбъектов";
				ЭтоГруппа      = "Значения.ЭтоГруппа";
			Иначе
				ИмяСправочника = "ЗначенияСвойствОбъектовИерархия";
				ЭтоГруппа      = "Ложь КАК ЭтоГруппа";
			КонецЕсли;
			
			Запрос.Текст =
			"ВЫБРАТЬ
			|	Значения.Ссылка КАК Ссылка,
			|	Значения.Родитель КАК РодительСсылки,
			|	Значения.ЭтоГруппа,
			|	Значения.ПометкаУдаления,
			|	Значения.Наименование,
			|	Значения.Вес
			|ИЗ
			|	Справочник.ЗначенияСвойствОбъектов КАК Значения
			|ГДЕ
			|	Значения.Владелец = &Владелец
			|ИТОГИ ПО
			|	Ссылка ИЕРАРХИЯ";
			Запрос.Текст = СтрЗаменить(Запрос.Текст, "ЗначенияСвойствОбъектов", ИмяСправочника);
			Запрос.Текст = СтрЗаменить(Запрос.Текст, "Значения.ЭтоГруппа", ЭтоГруппа);
			
			Выгрузка = Запрос.Выполнить().Выгрузить(ОбходРезультатаЗапроса.ПоГруппировкамСИерархией);
			СоздатьГруппыИЗначения(Выгрузка.Строки, СоответствиеСсылок, ИмяСправочника, СвойствоОбъект.Ссылка);
			
		ИначеЕсли Свойство = СвойствоОбъект.Ссылка Тогда
			ВызватьИсключение СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
				НСтр("ru = 'Ошибка при изменении настройки свойства %1.
				           |Тип значения не содержит дополнительных значений.'"),
				Свойство);
		КонецЕсли;
		
		Если Свойство <> СвойствоОбъект.Ссылка
		 ИЛИ СоответствиеСсылок.Количество() > 0 Тогда
			
			Блокировка = Новый БлокировкаДанных;
			
			ЭлементБлокировки = Блокировка.Добавить("РегистрСведений.ДополнительныеСведения");
			ЭлементБлокировки.УстановитьЗначение("Свойство", Свойство);
			
			ЭлементБлокировки = Блокировка.Добавить("РегистрСведений.ДополнительныеСведения");
			ЭлементБлокировки.УстановитьЗначение("Свойство", СвойствоОбъект.Ссылка);
			
			// Если исходное свойство общее, тогда нужно получить список наборов
			// объекта (по каждой ссылке) и, если заменяемое общее свойство есть
			// не только в целевом наборе, тогда добавить новое свойство и значение.
			//
			// Для исходных общих свойств, когда у владельцев их значений несколько наборов свойств,
			// процедура может быть особенно долгой, т.к. требует анализа наборов для каждого объекта владельца
			// из-за наличия переопределения состава наборов в процедуре ЗаполнитьНаборыСвойствОбъекта
			// общего модуля УправлениеСвойствамиПереопределяемый.
			
			ВладелецСДополнительнымиРеквизитами = Ложь;
			
			Если УправлениеСвойствамиСлужебный.ЭтоОбъектМетаданныхСДополнительнымиРеквизитами(МетаданныеВладельца) Тогда
				ВладелецСДополнительнымиРеквизитами = Истина;
				ЭлементБлокировки = Блокировка.Добавить(ПолноеИмяВладельца);
			КонецЕсли;
			
			Блокировка.Заблокировать();
			
			ТребуетсяАнализНаборовКаждогоОбъектаВладельца = Ложь;
			
			Если Свойство <> СвойствоОбъект.Ссылка Тогда
				
				ИмяПредопределенного = СтрЗаменить(МетаданныеВладельца.ПолноеИмя(), ".", "_");
				НаборСвойств = УправлениеСвойствами.НаборСвойствПоИмени(ИмяПредопределенного);
				Если НаборСвойств = Неопределено Тогда
					ТребуетсяАнализНаборовКаждогоОбъектаВладельца = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(
						"Справочник.НаборыДополнительныхРеквизитовИСведений." + ИмяПредопределенного, "ЭтоГруппа");
				Иначе
					ТребуетсяАнализНаборовКаждогоОбъектаВладельца = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(
						НаборСвойств, "ЭтоГруппа");
				КонецЕсли;
				// Если предопределенного нет в ИБ.
				Если ТребуетсяАнализНаборовКаждогоОбъектаВладельца = Неопределено Тогда 
					ТребуетсяАнализНаборовКаждогоОбъектаВладельца = Ложь;
				КонецЕсли;
				
			КонецЕсли;
			
			Если ТребуетсяАнализНаборовКаждогоОбъектаВладельца Тогда
				ЗапросАнализа = Новый Запрос;
				ЗапросАнализа.УстановитьПараметр("ОбщееСвойство", Свойство);
				ЗапросАнализа.УстановитьПараметр("НаборНовогоСвойства", ТекущийНаборСвойств);
				ЗапросАнализа.Текст =
				"ВЫБРАТЬ ПЕРВЫЕ 1
				|	ИСТИНА КАК ЗначениеИстина
				|ИЗ
				|	Справочник.НаборыДополнительныхРеквизитовИСведений.ДополнительныеСведения КАК НаборыСвойств
				|ГДЕ
				|	НаборыСвойств.Ссылка <> &НаборНовогоСвойства
				|	И НаборыСвойств.Ссылка В(&ВсеНаборыОбъекта)
				|	И НаборыСвойств.Свойство = &ОбщееСвойство";
			КонецЕсли;
			
			Запрос = Новый Запрос;
			
			Если Свойство = СвойствоОбъект.Ссылка Тогда
				// Если свойство не менялось (уже отдельное), а общий только список дополнительных значений,
				// тогда требуется замена только дополнительных значений.
				Запрос.МенеджерВременныхТаблиц = Новый МенеджерВременныхТаблиц;
				
				ТаблицаЗначений = Новый ТаблицаЗначений;
				ТаблицаЗначений.Колонки.Добавить("Значение", Новый ОписаниеТипов(
					"СправочникСсылка." + ИмяСправочника));
				
				Для каждого КлючИЗначение Из СоответствиеСсылок Цикл
					ТаблицаЗначений.Добавить().Значение = КлючИЗначение.Ключ;
				КонецЦикла;
				
				Запрос.УстановитьПараметр("ТаблицаЗначений", ТаблицаЗначений);
				
				Запрос.Текст =
				"ВЫБРАТЬ
				|	ТаблицаЗначений.Значение КАК Значение
				|ПОМЕСТИТЬ СтарыеЗначения
				|ИЗ
				|	&ТаблицаЗначений КАК ТаблицаЗначений
				|
				|ИНДЕКСИРОВАТЬ ПО
				|	Значение";
				Запрос.Выполнить();
			КонецЕсли;
			
			Запрос.УстановитьПараметр("Свойство", Свойство);
			ТипыДополнительныхЗначений = Новый Соответствие;
			ТипыДополнительныхЗначений.Вставить(Тип("СправочникСсылка.ЗначенияСвойствОбъектов"), Истина);
			ТипыДополнительныхЗначений.Вставить(Тип("СправочникСсылка.ЗначенияСвойствОбъектовИерархия"), Истина);
			
			// Замена дополнительных сведений.
			
			Если Свойство = СвойствоОбъект.Ссылка Тогда
				// Если свойство не менялось (уже отдельное), а общий только список дополнительных значений,
				// тогда требуется замена только дополнительных значений.
				Запрос.Текст =
				"ВЫБРАТЬ ПЕРВЫЕ 1000
				|	ДополнительныеСведения.Объект
				|ИЗ
				|	РегистрСведений.ДополнительныеСведения КАК ДополнительныеСведения
				|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ СтарыеЗначения КАК СтарыеЗначения
				|		ПО (ТИПЗНАЧЕНИЯ(ДополнительныеСведения.Объект) = ТИП(Справочник.ЗначенияСвойствОбъектов))
				|			И (НЕ ДополнительныеСведения.Объект В (&ОбработанныеОбъекты))
				|			И (ДополнительныеСведения.Свойство = &Свойство)
				|			И ДополнительныеСведения.Значение = СтарыеЗначения.Значение";
			Иначе
				// Если свойство меняется (общее свойство становится отдельным и дополнительные значения копируются),
				// тогда требуется замена свойства и дополнительных значений.
				Запрос.Текст =
				"ВЫБРАТЬ ПЕРВЫЕ 1000
				|	ДополнительныеСведения.Объект
				|ИЗ
				|	РегистрСведений.ДополнительныеСведения КАК ДополнительныеСведения
				|ГДЕ
				|	ТИПЗНАЧЕНИЯ(ДополнительныеСведения.Объект) = ТИП(Справочник.ЗначенияСвойствОбъектов)
				|	И НЕ ДополнительныеСведения.Объект В (&ОбработанныеОбъекты)
				|	И ДополнительныеСведения.Свойство = &Свойство";
			КонецЕсли;
			
			Запрос.Текст = СтрЗаменить(Запрос.Текст, "Справочник.ЗначенияСвойствОбъектов", ПолноеИмяВладельца);
			
			НаборСтаройЗаписи = РегистрыСведений.ДополнительныеСведения.СоздатьНаборЗаписей();
			НаборНовойЗаписи  = РегистрыСведений.ДополнительныеСведения.СоздатьНаборЗаписей();
			НаборНовойЗаписи.Добавить();
			
			ОбработанныеОбъекты = Новый Массив;
			
			Пока Истина Цикл
				Запрос.УстановитьПараметр("ОбработанныеОбъекты", ОбработанныеОбъекты);
				Выборка = Запрос.Выполнить().Выбрать();
				Если Выборка.Количество() = 0 Тогда
					Прервать;
				КонецЕсли;
				Пока Выборка.Следующий() Цикл
					Заменить = Истина;
					Если ТребуетсяАнализНаборовКаждогоОбъектаВладельца Тогда
						ЗапросАнализа.УстановитьПараметр("ВсеНаборыОбъекта",
							УправлениеСвойствамиСлужебный.ПолучитьНаборыСвойствОбъекта(
								Выборка.Объект).ВыгрузитьКолонку("Набор"));
						Заменить = ЗапросАнализа.Выполнить().Пустой();
					КонецЕсли;
					НаборСтаройЗаписи.Отбор.Объект.Установить(Выборка.Объект);
					НаборСтаройЗаписи.Отбор.Свойство.Установить(Свойство);
					НаборСтаройЗаписи.Прочитать();
					Если НаборСтаройЗаписи.Количество() > 0 Тогда
						НаборНовойЗаписи[0].Объект   = Выборка.Объект;
						НаборНовойЗаписи[0].Свойство = СвойствоОбъект.Ссылка;
						Значение = НаборСтаройЗаписи[0].Значение;
						Если ТипыДополнительныхЗначений[ТипЗнч(Значение)] = Неопределено Тогда
							НаборНовойЗаписи[0].Значение = Значение;
						Иначе
							НаборНовойЗаписи[0].Значение = СоответствиеСсылок[Значение];
						КонецЕсли;
						НаборНовойЗаписи.Отбор.Объект.Установить(Выборка.Объект);
						НаборНовойЗаписи.Отбор.Свойство.Установить(НаборНовойЗаписи[0].Свойство);
						Если Заменить Тогда
							НаборСтаройЗаписи.Очистить();
							НаборСтаройЗаписи.ОбменДанными.Загрузка = Истина;
							НаборСтаройЗаписи.Записать();
						Иначе
							ОбработанныеОбъекты.Добавить(Выборка.Объект);
						КонецЕсли;
						НаборНовойЗаписи.ОбменДанными.Загрузка = Истина;
						НаборНовойЗаписи.Записать();
					КонецЕсли;
				КонецЦикла;
			КонецЦикла;
			
			// Замена дополнительных реквизитов.
			
			Если ВладелецСДополнительнымиРеквизитами Тогда
				
				Если ТребуетсяАнализНаборовКаждогоОбъектаВладельца Тогда
					ЗапросАнализа = Новый Запрос;
					ЗапросАнализа.УстановитьПараметр("ОбщееСвойство", Свойство);
					ЗапросАнализа.УстановитьПараметр("НаборНовогоСвойства", ТекущийНаборСвойств);
					ЗапросАнализа.Текст =
					"ВЫБРАТЬ ПЕРВЫЕ 1
					|	ИСТИНА КАК ЗначениеИстина
					|ИЗ
					|	Справочник.НаборыДополнительныхРеквизитовИСведений.ДополнительныеРеквизиты КАК НаборыСвойств
					|ГДЕ
					|	НаборыСвойств.Ссылка <> &НаборНовогоСвойства
					|	И НаборыСвойств.Ссылка В(&ВсеНаборыОбъекта)
					|	И НаборыСвойств.Свойство = &ОбщееСвойство";
				КонецЕсли;
				
				Если Свойство = СвойствоОбъект.Ссылка Тогда
					// Если свойство не менялось (уже отдельное), а общий только список дополнительных значений,
					// тогда требуется замена только дополнительных значений.
					Запрос.Текст =
					"ВЫБРАТЬ ПЕРВЫЕ 1000
					|	ТекущаяТаблица.Ссылка КАК Ссылка
					|ИЗ
					|	ИмяТаблицы КАК ТекущаяТаблица
					|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ СтарыеЗначения КАК СтарыеЗначения
					|		ПО (НЕ ТекущаяТаблица.Ссылка В (&ОбработанныеОбъекты))
					|			И (ТекущаяТаблица.Свойство = &Свойство)
					|			И ТекущаяТаблица.Значение = СтарыеЗначения.Значение";
				Иначе
					// Если свойство меняется (общее свойство становится отдельным и дополнительные значения копируются),
					// тогда требуется замена свойства и дополнительных значений.
					Запрос.Текст =
					"ВЫБРАТЬ ПЕРВЫЕ 1000
					|	ТекущаяТаблица.Ссылка КАК Ссылка
					|ИЗ
					|	ИмяТаблицы КАК ТекущаяТаблица
					|ГДЕ
					|	НЕ ТекущаяТаблица.Ссылка В (&ОбработанныеОбъекты)
					|	И ТекущаяТаблица.Свойство = &Свойство";
				КонецЕсли;
				Запрос.Текст = СтрЗаменить(Запрос.Текст, "ИмяТаблицы", ПолноеИмяВладельца + ".ДополнительныеРеквизиты");
				
				ОбработанныеОбъекты = Новый Массив;
				
				Пока Истина Цикл
					Запрос.УстановитьПараметр("ОбработанныеОбъекты", ОбработанныеОбъекты);
					Выборка = Запрос.Выполнить().Выбрать();
					Если Выборка.Количество() = 0 Тогда
						Прервать;
					КонецЕсли;
					Пока Выборка.Следующий() Цикл
						ТекущийОбъект = Выборка.Ссылка.ПолучитьОбъект();
						Заменить = Истина;
						Если ТребуетсяАнализНаборовКаждогоОбъектаВладельца Тогда
							ЗапросАнализа.УстановитьПараметр("ВсеНаборыОбъекта",
								УправлениеСвойствамиСлужебный.ПолучитьНаборыСвойствОбъекта(
									Выборка.Ссылка).ВыгрузитьКолонку("Набор"));
							Заменить = ЗапросАнализа.Выполнить().Пустой();
						КонецЕсли;
						Для каждого Строка Из ТекущийОбъект.ДополнительныеРеквизиты Цикл
							Если Строка.Свойство = Свойство Тогда
								Значение = Строка.Значение;
								Если ТипыДополнительныхЗначений[ТипЗнч(Значение)] <> Неопределено Тогда
									Значение = СоответствиеСсылок[Значение];
								КонецЕсли;
								Если Заменить Тогда
									Если Строка.Свойство <> СвойствоОбъект.Ссылка Тогда
										Строка.Свойство = СвойствоОбъект.Ссылка;
									КонецЕсли;
									Если Строка.Значение <> Значение Тогда
										Строка.Значение = Значение;
									КонецЕсли;
								Иначе
									НоваяСтрока = ТекущийОбъект.ДополнительныеРеквизиты.Добавить();
									НоваяСтрока.Свойство = СвойствоОбъект.Ссылка;
									НоваяСтрока.Значение = Значение;
									ОбработанныеОбъекты.Добавить(ТекущийОбъект.Ссылка);
									Прервать;
								КонецЕсли;
							КонецЕсли;
						КонецЦикла;
						Если ТекущийОбъект.Модифицированность() Тогда
							ТекущийОбъект.ОбменДанными.Загрузка = Истина;
							ТекущийОбъект.Записать();
						КонецЕсли;
					КонецЦикла;
				КонецЦикла;
			КонецЕсли;
			
			Если Свойство = СвойствоОбъект.Ссылка Тогда
				Запрос.МенеджерВременныхТаблиц.Закрыть();
			КонецЕсли;
		КонецЕсли;
		
		ЗафиксироватьТранзакцию();
	Исключение
		ОтменитьТранзакцию();
		ВызватьИсключение;
	КонецПопытки;
	
	ПоместитьВоВременноеХранилище(ОткрытьСвойство, АдресХранилища);
	
КонецПроцедуры

Процедура СоздатьГруппыИЗначения(Строки, СоответствиеСсылок, ИмяСправочника, Свойство, СтарыйРодитель = Неопределено)
	
	Для каждого Строка Из Строки Цикл
		Если Строка.Ссылка = СтарыйРодитель Тогда
			Продолжить;
		КонецЕсли;
		
		Если Строка.ЭтоГруппа = Истина Тогда
			НовыйОбъект = Справочники[ИмяСправочника].СоздатьГруппу();
			ЗаполнитьЗначенияСвойств(НовыйОбъект, Строка, "Наименование, ПометкаУдаления");
		Иначе
			НовыйОбъект = Справочники[ИмяСправочника].СоздатьЭлемент();
			ЗаполнитьЗначенияСвойств(НовыйОбъект, Строка, "Наименование, Вес, ПометкаУдаления");
		КонецЕсли;
		НовыйОбъект.Владелец = Свойство;
		Если ЗначениеЗаполнено(Строка.РодительСсылки) Тогда
			НовыйОбъект.Родитель = СоответствиеСсылок[Строка.РодительСсылки];
		КонецЕсли;
		НовыйОбъект.Записать();
		СоответствиеСсылок.Вставить(Строка.Ссылка, НовыйОбъект.Ссылка);
		
		СоздатьГруппыИЗначения(Строка.Строки, СоответствиеСсылок, ИмяСправочника, Свойство, Строка.Ссылка);
	КонецЦикла;
	
КонецПроцедуры

Процедура ЗарегистрироватьДанныеКОбработкеДляПереходаНаНовуюВерсию(Параметры) Экспорт
	
	// Получение наборов свойств с префиксом Удалить.
	НаборыСвойств = Новый Массив;
	ИменаПредопределенныхНаборов = Метаданные.Справочники.НаборыДополнительныхРеквизитовИСведений.ПолучитьИменаПредопределенных();
	Для Каждого ИмяПредопределенногоНабора Из ИменаПредопределенныхНаборов Цикл
		Если СтрНачинаетсяС(ИмяПредопределенногоНабора, "Удалить") Тогда
			Попытка
				ПредопределенныйНабор = Справочники.НаборыДополнительныхРеквизитовИСведений[ИмяПредопределенногоНабора];
				НаборыСвойств.Добавить(ПредопределенныйНабор);
			Исключение
				// Обработка исключения не требуется, отсутствует предопределенный элемент в данных.
				Продолжить;
			КонецПопытки;
		КонецЕсли;
	КонецЦикла;
	НаборыСвойств.Добавить(Справочники.НаборыДополнительныхРеквизитовИСведений.ПустаяСсылка());
	
	Запрос = Новый Запрос;
	Запрос.Текст =
		"ВЫБРАТЬ
		|	ДополнительныеРеквизитыИСведения.Ссылка КАК Ссылка
		|ИЗ
		|	ПланВидовХарактеристик.ДополнительныеРеквизитыИСведения КАК ДополнительныеРеквизитыИСведения
		|ГДЕ
		|	ДополнительныеРеквизитыИСведения.Имя ПОДОБНО """"
		|	ИЛИ ДополнительныеРеквизитыИСведения.Имя ПОДОБНО ""%-%""
		|	ИЛИ ДополнительныеРеквизитыИСведения.Имя ПОДОБНО ""%«%""
		|
		|ОБЪЕДИНИТЬ ВСЕ
		|
		|ВЫБРАТЬ
		|	ЗависимостиДополнительныхРеквизитов.Ссылка КАК Ссылка
		|ИЗ
		|	ПланВидовХарактеристик.ДополнительныеРеквизитыИСведения.ЗависимостиДополнительныхРеквизитов КАК ЗависимостиДополнительныхРеквизитов
		|ГДЕ
		|	ЗависимостиДополнительныхРеквизитов.НаборСвойств В (&НаборыСвойств)
		|
		|ОБЪЕДИНИТЬ ВСЕ
		|
		|ВЫБРАТЬ
		|	ДополнительныеРеквизитыИСведения.Ссылка
		|ИЗ
		|	ПланВидовХарактеристик.ДополнительныеРеквизитыИСведения КАК ДополнительныеРеквизитыИСведения
		|ГДЕ
		|	ИдентификаторДляФормул = """"";
		
	Запрос.УстановитьПараметр("НаборыСвойств", НаборыСвойств);
	
	Результат = Запрос.Выполнить().Выгрузить();
	МассивСсылок = Результат.ВыгрузитьКолонку("Ссылка");
	
	ОбновлениеИнформационнойБазы.ОтметитьКОбработке(Параметры, МассивСсылок);
	
КонецПроцедуры

Процедура ОбработатьДанныеДляПереходаНаНовуюВерсию(Параметры) Экспорт
	
	ПолноеИмя = "ПланВидовХарактеристик.ДополнительныеРеквизитыИСведения";
	Выборка = ОбновлениеИнформационнойБазы.ВыбратьСсылкиДляОбработки(Параметры.Очередь, ПолноеИмя);
	
	ПроблемныхОбъектов = 0;
	ОбъектовОбработано = 0;
	
	Пока Выборка.Следующий() Цикл
		
		НачатьТранзакцию();
		Попытка
			// Блокируем объект от изменения другими сеансами.
			Блокировка = Новый БлокировкаДанных;
			ЭлементБлокировки = Блокировка.Добавить(ПолноеИмя);
			Ссылка = Выборка.Ссылка; // ПланВидовХарактеристикСсылка.ДополнительныеРеквизитыИСведения - 
			ЭлементБлокировки.УстановитьЗначение("Ссылка", Ссылка);
			Блокировка.Заблокировать();
			
			Объект = Ссылка.ПолучитьОбъект();
			
			Если Не ЗначениеЗаполнено(Объект.Имя) Тогда
				УстановитьИмяРеквизита(Выборка, Объект);
			Иначе
				УправлениеСвойствамиСлужебный.УдалитьНедопустимыеСимволы(Объект.Имя);
			КонецЕсли;
			
			Для Каждого Зависимость Из Объект.ЗависимостиДополнительныхРеквизитов Цикл
				ИмяПредопределенныхДанных = "";
				Если ЗначениеЗаполнено(Зависимость.НаборСвойств) Тогда
					ИмяПредопределенныхДанных = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Зависимость.НаборСвойств, "ИмяПредопределенныхДанных");
					Если Не СтрНачинаетсяС(ИмяПредопределенныхДанных, "Удалить") Тогда
						Продолжить;
					КонецЕсли;
				КонецЕсли;
				Если Не ЗначениеЗаполнено(ИмяПредопределенныхДанных) Тогда
					Зависимость.НаборСвойств = Объект.НаборСвойств;
				Иначе
					ДлинаПрефикса = СтрДлина("Удалить");
					ИмяНабора = Сред(ИмяПредопределенныхДанных, ДлинаПрефикса + 1, СтрДлина(ИмяПредопределенныхДанных) - ДлинаПрефикса);
					НовыйНабор = УправлениеСвойствами.НаборСвойствПоИмени(ИмяНабора);
					Если НовыйНабор <> Неопределено Тогда
						Зависимость.НаборСвойств = НовыйНабор;
					КонецЕсли;
				КонецЕсли;
			КонецЦикла;
			
			Если НЕ ЗначениеЗаполнено(Объект.ИдентификаторДляФормул) Тогда
				ЗаголовокДляФормул = ЗаголовокДляФормированияИдентификатора(Объект.Заголовок, Объект.Представления);
				Объект.ИдентификаторДляФормул = УникальныйИдентификаторДляФормул(ЗаголовокДляФормул, Объект.Ссылка);
			КонецЕсли;
			
			ОбновлениеИнформационнойБазы.ЗаписатьДанные(Объект);
			ОбъектовОбработано = ОбъектовОбработано + 1;
			
			ЗафиксироватьТранзакцию();
		Исключение
			ОтменитьТранзакцию();
			ПроблемныхОбъектов = ПроблемныхОбъектов + 1;
			
			ТекстСообщения = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
				НСтр("ru = 'Не удалось обработать дополнительный реквизит (сведение) %1 по причине:
					|%2'"), 
				Выборка.Ссылка, ПодробноеПредставлениеОшибки(ИнформацияОбОшибке()));
			ЗаписьЖурналаРегистрации(ОбновлениеИнформационнойБазы.СобытиеЖурналаРегистрации(), УровеньЖурналаРегистрации.Предупреждение,
				Метаданные.ПланыВидовХарактеристик.ДополнительныеРеквизитыИСведения, Выборка.Ссылка, ТекстСообщения);
		КонецПопытки;
		
	КонецЦикла;
	
	Параметры.ОбработкаЗавершена = ОбновлениеИнформационнойБазы.ОбработкаДанныхЗавершена(Параметры.Очередь, ПолноеИмя);
	Если ОбъектовОбработано = 0 И ПроблемныхОбъектов <> 0 Тогда
		ТекстСообщения = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			НСтр("ru = 'Не удалось обработать некоторые дополнительные реквизиты или сведения (пропущены): %1'"), 
			ПроблемныхОбъектов);
		ВызватьИсключение ТекстСообщения;
	Иначе
		ЗаписьЖурналаРегистрации(ОбновлениеИнформационнойБазы.СобытиеЖурналаРегистрации(), УровеньЖурналаРегистрации.Информация,
			Метаданные.ПланыВидовХарактеристик.ДополнительныеРеквизитыИСведения,,
			СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(НСтр("ru = 'Обработана очередная порция дополнительных реквизитов (сведений): %1'"),
				ОбъектовОбработано));
	КонецЕсли;
	
КонецПроцедуры

Процедура УстановитьИмяРеквизита(Выборка, Объект)
	
	ЗаголовокОбъекта = Объект.Заголовок;
	УправлениеСвойствамиСлужебный.УдалитьНедопустимыеСимволы(ЗаголовокОбъекта);
	ЗаголовокОбъектаЧастями = СтрРазделить(ЗаголовокОбъекта, " ", Ложь);
	Для Каждого ЧастьЗаголовка Из ЗаголовокОбъектаЧастями Цикл
		Объект.Имя = Объект.Имя + ВРег(Лев(ЧастьЗаголовка, 1)) + Сред(ЧастьЗаголовка, 2);
	КонецЦикла;
	
	// Проверка уникальности имени.
	Если ИмяИспользуется(Выборка.Ссылка, Объект.Имя) Тогда
		УИД = Новый УникальныйИдентификатор();
		СтрокаУИД = СтрЗаменить(Строка(УИД), "-", "");
		Объект.Имя = Объект.Имя + "_" + СтрокаУИД;
	КонецЕсли;

КонецПроцедуры

Функция ИмяИспользуется(Ссылка, Имя)
	
	Запрос = Новый Запрос;
	Запрос.Текст =
		"ВЫБРАТЬ ПЕРВЫЕ 1
		|	Свойства.ЭтоДополнительноеСведение
		|ИЗ
		|	ПланВидовХарактеристик.ДополнительныеРеквизитыИСведения КАК Свойства
		|ГДЕ
		|	Свойства.Имя = &Имя
		|	И Свойства.Ссылка <> &Ссылка";
	Запрос.УстановитьПараметр("Ссылка", Ссылка);
	Запрос.УстановитьПараметр("Имя",    Имя);
	
	Возврат Не Запрос.Выполнить().Пустой();
	
КонецФункции

#КонецОбласти

#КонецЕсли