﻿///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2023, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область СлужебныеПроцедурыИФункции

// Формирует ключ разрешения (для использования в регистрах, в которых хранится информация о
// предоставленных разрешениях).
//
// Параметры:
//  Разрешение - ОбъектXDTO.
//
// Возвращаемое значение:
//   Строка
//
Функция КлючРазрешения(Знач Разрешение) Экспорт
	
	Хеширование = Новый ХешированиеДанных(ХешФункция.MD5);
	Хеширование.Добавить(ОбщегоНазначения.ОбъектXDTOВСтрокуXML(Разрешение));
	
	Дополнение = ДополнениеРазрешения(Разрешение);
	Если ЗначениеЗаполнено(Дополнение) Тогда
		Хеширование.Добавить(ОбщегоНазначения.ЗначениеВСтрокуXML(Дополнение));
	КонецЕсли;
	
	Ключ = ФабрикаXDTO.Создать(ФабрикаXDTO.Тип("http://www.w3.org/2001/XMLSchema", "hexBinary"), Хеширование.ХешСумма).ЛексическоеЗначение;
	
	Если СтрДлина(Ключ) > 32 Тогда
		ВызватьИсключение НСтр("ru = 'Превышение длины ключа';
								|en = 'Key length exceeded'");
	КонецЕсли;
	
	Возврат Ключ;
	
КонецФункции

// Формирует дополнение разрешения.
//
// Параметры:
//  Разрешение - ОбъектXDTO.
//
// Возвращаемое значение:
//   Произвольный
//
Функция ДополнениеРазрешения(Знач Разрешение) Экспорт
	
	Если Разрешение.Тип() = ФабрикаXDTO.Тип(РаботаВБезопасномРежимеСлужебный.Пакет(), "AttachAddin") Тогда
		Возврат РаботаВБезопасномРежимеСлужебный.КонтрольныеСуммыФайловКомплектаВнешнейКомпоненты(Разрешение.TemplateName);
	Иначе
		Возврат Неопределено;
	КонецЕсли;
	
КонецФункции

// Возвращает текущий срез предоставленных разрешений.
//
// Параметры:
//  ВРазрезеВладельцев - Булево - если Истина - в возвращаемой таблице будет присутствовать информация
//    о владельцах разрешений, иначе текущий срез будет свернут по владельцу,
//  БезОписаний - Булево - если Истина - срез будет возвращен с очищенным полем Description у разрешений.
//
// Возвращаемое значение:
//   ТаблицаЗначений:
//   * ТипПрограммногоМодуля - СправочникСсылка.ИдентификаторыОбъектовМетаданных
//   * ИдентификаторПрограммногоМодуля - УникальныйИдентификатор
//   * ТипВладельца - СправочникСсылка.ИдентификаторыОбъектовМетаданных
//   * ИдентификаторВладельца - УникальныйИдентификатор
//   * Тип - Строка - имя XDTO-типа, описывающего разрешения.
//   * Разрешения - Соответствие из КлючИЗначение:
//       ** Ключ - см. РегистрСведений.РазрешенияНаИспользованиеВнешнихРесурсов.КлючРазрешения
//       ** Значение - ОбъектXDTO - XDTO-описание разрешения.
//   * ДополненияРазрешений - Соответствие из КлючИЗначение - описание дополнений разрешений:
//       ** Ключ - см. РегистрСведений.РазрешенияНаИспользованиеВнешнихРесурсов.КлючРазрешения
//       ** Значение - см. РегистрСведений.РазрешенияНаИспользованиеВнешнихРесурсов.ДополнениеРазрешения
//
Функция СрезРазрешений(Знач ВРазрезеВладельцев = Истина, Знач БезОписаний = Ложь) Экспорт
	
	Результат = Новый ТаблицаЗначений();
	
	Результат.Колонки.Добавить("ТипПрограммногоМодуля", Новый ОписаниеТипов("СправочникСсылка.ИдентификаторыОбъектовМетаданных"));
	Результат.Колонки.Добавить("ИдентификаторПрограммногоМодуля", Новый ОписаниеТипов("УникальныйИдентификатор"));
	Если ВРазрезеВладельцев Тогда
		Результат.Колонки.Добавить("ТипВладельца", Новый ОписаниеТипов("СправочникСсылка.ИдентификаторыОбъектовМетаданных"));
		Результат.Колонки.Добавить("ИдентификаторВладельца", Новый ОписаниеТипов("УникальныйИдентификатор"));
	КонецЕсли;
	Результат.Колонки.Добавить("Тип", Новый ОписаниеТипов("Строка"));
	Результат.Колонки.Добавить("Разрешения", Новый ОписаниеТипов("Соответствие"));
	Результат.Колонки.Добавить("ДополненияРазрешений", Новый ОписаниеТипов("Соответствие"));
	
	Выборка = Выбрать();
	
	Пока Выборка.Следующий() Цикл
		
		Разрешение = ОбщегоНазначения.ОбъектXDTOИзСтрокиXML(Выборка.ТелоРазрешения);
		
		ОтборПоТаблице = Новый Структура();
		ОтборПоТаблице.Вставить("ТипПрограммногоМодуля", Выборка.ТипПрограммногоМодуля);
		ОтборПоТаблице.Вставить("ИдентификаторПрограммногоМодуля", Выборка.ИдентификаторПрограммногоМодуля);
		Если ВРазрезеВладельцев Тогда
			ОтборПоТаблице.Вставить("ТипВладельца", Выборка.ТипВладельца);
			ОтборПоТаблице.Вставить("ИдентификаторВладельца", Выборка.ИдентификаторВладельца);
		КонецЕсли;
		ОтборПоТаблице.Вставить("Тип", Разрешение.Тип().Имя);
		
		Строка = Обработки.НастройкаРазрешенийНаИспользованиеВнешнихРесурсов.СтрокаТаблицыРазрешений(
			Результат, ОтборПоТаблице);
		
		ТелоРазрешения = Выборка.ТелоРазрешения;
		КлючРазрешения = Выборка.КлючРазрешения;
		ДополнениеРазрешения = Выборка.ДополнениеРазрешения;
		
		Если БезОписаний Тогда
			
			Если ЗначениеЗаполнено(Разрешение.Description) Тогда
				
				Разрешение.Description = "";
				ТелоРазрешения = ОбщегоНазначения.ОбъектXDTOВСтрокуXML(Разрешение);
				КлючРазрешения = КлючРазрешения(Разрешение);
				
			КонецЕсли;
			
		КонецЕсли;
		
		Строка.Разрешения.Вставить(КлючРазрешения, ТелоРазрешения);
		
		Если ЗначениеЗаполнено(ДополнениеРазрешения) Тогда
			Строка.ДополненияРазрешений.Вставить(КлючРазрешения, ДополнениеРазрешения);
		КонецЕсли;
		
	КонецЦикла;
	
	Возврат Результат;
	
КонецФункции

// Записывает в регистр разрешение.
//
// Параметры:
//  ТипПрограммногоМодуля - СправочникСсылка.ИдентификаторыОбъектовМетаданных,
//  ИдентификаторПрограммногоМодуля - УникальныйИдентификатор,
//  ТипВладельца - СправочникСсылка.ИдентификаторыОбъектовМетаданных,
//  ИдентификаторВладельца - УникальныйИдентификатор,
//  КлючРазрешения - Строка - ключ разрешения,
//  Разрешение - ОбъектXDTO - XDTO-представление разрешения,
//  ДополнениеРазрешения - Произвольный (сериализуемый в XDTO).
//
Процедура ДобавитьРазрешение(Знач ТипПрограммногоМодуля, Знач ИдентификаторПрограммногоМодуля, Знач ТипВладельца, Знач ИдентификаторВладельца, Знач КлючРазрешения, Знач Разрешение, Знач ДополнениеРазрешения = Неопределено) Экспорт
	
	Менеджер = СоздатьМенеджерЗаписи();
	Менеджер.ТипПрограммногоМодуля = ТипПрограммногоМодуля;
	Менеджер.ИдентификаторПрограммногоМодуля = ИдентификаторПрограммногоМодуля;
	Менеджер.ТипВладельца = ТипВладельца;
	Менеджер.ИдентификаторВладельца = ИдентификаторВладельца;
	Менеджер.КлючРазрешения = КлючРазрешения;
	
	Менеджер.Прочитать();
	
	Если Менеджер.Выбран() Тогда
		
		ВызватьИсключение СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			НСтр("ru = 'Добавляемое разрешение уже существует:
				|%1, %2, %3, %4, %5.';
				|en = 'The extension to be added already exists:
				|%1, %2, %3, %4, %5.'"),
			Строка(ТипПрограммногоМодуля),
			Строка(ИдентификаторПрограммногоМодуля),
			Строка(ТипВладельца),
			Строка(ИдентификаторВладельца),
			КлючРазрешения);
		
	Иначе
		
		Менеджер.ТипПрограммногоМодуля = ТипПрограммногоМодуля;
		Менеджер.ИдентификаторПрограммногоМодуля = ИдентификаторПрограммногоМодуля;
		Менеджер.ТипВладельца = ТипВладельца;
		Менеджер.ИдентификаторВладельца = ИдентификаторВладельца;
		Менеджер.КлючРазрешения = КлючРазрешения;
		Менеджер.ТелоРазрешения = ОбщегоНазначения.ОбъектXDTOВСтрокуXML(Разрешение);
		
		Если ЗначениеЗаполнено(ДополнениеРазрешения) Тогда
			Менеджер.ДополнениеРазрешения = ОбщегоНазначения.ЗначениеВСтрокуXML(ДополнениеРазрешения);
		КонецЕсли;
		
		Менеджер.Записать(Ложь);
		
	КонецЕсли;
	
КонецПроцедуры

// Удаляет разрешение из регистра.
//
// Параметры:
//  ТипПрограммногоМодуля - СправочникСсылка.ИдентификаторыОбъектовМетаданных,
//  ИдентификаторПрограммногоМодуля - УникальныйИдентификатор,
//  ТипВладельца - СправочникСсылка.ИдентификаторыОбъектовМетаданных,
//  ИдентификаторВладельца - УникальныйИдентификатор,
//  КлючРазрешения - Строка - ключ разрешения,
//  Разрешение - ОбъектXDTO - XDTO-представление разрешения.
//
Процедура УдалитьРазрешение(Знач ТипПрограммногоМодуля, Знач ИдентификаторПрограммногоМодуля, Знач ТипВладельца, Знач ИдентификаторВладельца, Знач КлючРазрешения, Знач Разрешение) Экспорт
	
	Менеджер = СоздатьМенеджерЗаписи();
	Менеджер.ТипПрограммногоМодуля = ТипПрограммногоМодуля;
	Менеджер.ИдентификаторПрограммногоМодуля = ИдентификаторПрограммногоМодуля;
	Менеджер.ТипВладельца = ТипВладельца;
	Менеджер.ИдентификаторВладельца = ИдентификаторВладельца;
	Менеджер.КлючРазрешения = КлючРазрешения;
	
	Менеджер.Прочитать();
	
	Если Менеджер.Выбран() Тогда
		
		Если Менеджер.ТелоРазрешения <> ОбщегоНазначения.ОбъектXDTOВСтрокуXML(Разрешение) Тогда
			
			ВызватьИсключение СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
				НСтр("ru = 'Позиция разрешений по ключам:
	                  |%1, %2, %3, %4, %5.';
	                  |en = 'Position of permissions by keys:
	                  |%1, %2, %3, %4, %5.'"),
				Строка(ТипПрограммногоМодуля),
				Строка(ИдентификаторПрограммногоМодуля),
				Строка(ТипВладельца),
				Строка(ИдентификаторВладельца),
				КлючРазрешения);
				
		КонецЕсли;
		
		Менеджер.Удалить();
		
	Иначе
		
		ВызватьИсключение СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			НСтр("ru = 'Попытка удаления несуществующего разрешения:
                  |%1, %2, %3, %4, %5.';
                  |en = 'Attempt to delete an extension that does not exist:
                  |%1, %2, %3, %4, %5.'"),
			Строка(ТипПрограммногоМодуля),
			Строка(ИдентификаторПрограммногоМодуля),
			Строка(ТипВладельца),
			Строка(ИдентификаторВладельца),
			КлючРазрешения);
		
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#КонецЕсли

