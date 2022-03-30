﻿///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2021, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область ОбработчикиСобытий

Процедура ПередЗаписью(Отказ)
	
	Если ОбменДанными.Загрузка Тогда
		Возврат;
	КонецЕсли;
	
	Если СтрНачинаетсяС(ИмяПредопределенныхДанных, "Удалить") Тогда
		Возврат;
	КонецЕсли;
	
	Если НЕ ЭтоГруппа Тогда
		Результат = УправлениеКонтактнойИнформациейСлужебный.ПроверитьПараметрыВидаКонтактнойИнформации(ЭтотОбъект);
		Если Результат.ЕстьОшибки Тогда
			Отказ = Истина;
			ВызватьИсключение Результат.ТекстОшибки;
		КонецЕсли;
		ИмяГруппы = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Родитель, "ИмяПредопределенногоВида");
		Если ПустаяСтрока(ИмяГруппы) Тогда
			ИмяГруппы = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Родитель, "ИмяПредопределенныхДанных");
		КонецЕсли;
		
		ПроверкаИдентификатораДляФормул(Отказ);
	КонецЕсли;
	
КонецПроцедуры

Процедура ПриЗаписи(Отказ)
	
	Если ОбменДанными.Загрузка Тогда
		Возврат;
	КонецЕсли;
	
	УстановитьСостояниеРегламентногоЗадания();
	
КонецПроцедуры

Процедура ОбработкаПроверкиЗаполнения(Отказ, ПроверяемыеРеквизиты)
	
	Если СтрНачинаетсяС(ИмяПредопределенныхДанных, "Удалить") Тогда
		ПроверяемыеРеквизиты.Очистить();
		Возврат;
	КонецЕсли;
	
	Если ЭтоГруппа Тогда
		
		НепроверяемыеРеквизиты = Новый Массив;
		НепроверяемыеРеквизиты.Добавить("Родитель");
		ОбщегоНазначения.УдалитьНепроверяемыеРеквизитыИзМассива(ПроверяемыеРеквизиты, НепроверяемыеРеквизиты);
	
	КонецЕсли;
	
КонецПроцедуры

Процедура ПриКопировании(ОбъектКопирования)
	ИмяПредопределенногоВида = "";
	Если НЕ ЭтоГруппа Тогда
		ИдентификаторДляФормул = "";
	КонецЕсли;
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

Процедура ПроверкаИдентификатораДляФормул(Отказ)
	Если НЕ ДополнительныеСвойства.Свойство("ПроверкаИдентификатораДляФормулВыполнена") Тогда
		// Программная запись.
		Если ЗначениеЗаполнено(ИдентификаторДляФормул) Тогда
			Справочники.ВидыКонтактнойИнформации.ПроверитьУникальностьИдентификатора(ИдентификаторДляФормул,
				Ссылка, Родитель, Отказ);
		Иначе
			// Установка идентификатора.
			ИдентификаторДляФормул = Справочники.ВидыКонтактнойИнформации.УникальныйИдентификаторДляФормул(
				НаименованиеДляФормированияИдентификатора(), Ссылка, Родитель);
		КонецЕсли;
	КонецЕсли;
КонецПроцедуры

Функция НаименованиеДляФормированияИдентификатора()
	
	Если ОбщегоНазначения.ПодсистемаСуществует("СтандартныеПодсистемы.Мультиязычность") Тогда
		МодульМультиязычностьСервер = ОбщегоНазначения.ОбщийМодуль("МультиязычностьСервер");
		СуффиксТекущегоЯзыка = МодульМультиязычностьСервер.СуффиксТекущегоЯзыка();
		ЗаголовокДляИдентификатора = ?(ЗначениеЗаполнено(СуффиксТекущегоЯзыка),
			ЭтотОбъект["Наименование"+ СуффиксТекущегоЯзыка],
			Наименование);
	Иначе
		ЗаголовокДляИдентификатора = Наименование;
	КонецЕсли;
	
	Возврат ЗаголовокДляИдентификатора;

КонецФункции

Процедура ПриЧтенииПредставленийНаСервере() Экспорт
	
	Если ОбщегоНазначения.ПодсистемаСуществует("СтандартныеПодсистемы.Мультиязычность") Тогда
		МодульМультиязычностьСервер = ОбщегоНазначения.ОбщийМодуль("МультиязычностьСервер");
		МодульМультиязычностьСервер.ПриЧтенииПредставленийНаСервере(ЭтотОбъект);
	КонецЕсли;
	
КонецПроцедуры

Процедура УстановитьСостояниеРегламентногоЗадания()
	
	Статус = ?(ИсправлятьУстаревшиеАдреса = Истина, Истина, Неопределено);
	УправлениеКонтактнойИнформациейСлужебный.УстановитьИспользованиеРегламентногоЗадания(Статус);
	
КонецПроцедуры

#КонецОбласти

#Иначе
ВызватьИсключение НСтр("ru = 'Недопустимый вызов объекта на клиенте.'");
#КонецЕсли