﻿///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2023, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область ОписаниеПеременных

&НаКлиенте
Перем ЗаданиеАктивно;

#КонецОбласти

#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	АдресХранилища = ПоместитьВоВременноеХранилище(Неопределено, Новый УникальныйИдентификатор);
	АдресХранилищаСостояния = ПоместитьВоВременноеХранилище(Неопределено, Новый УникальныйИдентификатор);
	
	Элементы.Закрыть.Доступность = Не Параметры.РежимПроверки;
	
	НачатьОбработкуЗапросов(
		Параметры.Идентификаторы,
		Параметры.РежимВключения,
		Параметры.РежимОтключения,
		Параметры.РежимВосстановления,
		Параметры.РежимПроверки);
	
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	
	ЗаданиеАктивно = Истина;
	ИтерацияПроверки = 1;
	ПодключитьОбработчикОжиданияОбработкиЗапросов(3);
	
КонецПроцедуры

&НаКлиенте
Процедура ПередЗакрытием(Отказ, ЗавершениеРаботы, ТекстПредупреждения, СтандартнаяОбработка)
	
	Если ЗавершениеРаботы Тогда
		Возврат;
	КонецЕсли;
	
	Если ЗаданиеАктивно Тогда
		ОтменитьОбработкуЗапросов(ИдентификаторЗадания);
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаСервере
Функция НачатьОбработкуЗапросов(Знач Запросы, Знач РежимВключения, РежимОтключения, Знач РежимВосстановления, Знач РежимПроверкиПрименения)
	
	Если РежимВключения Тогда
		
		ПараметрыЗадания = Новый Массив();
		ПараметрыЗадания.Добавить(АдресХранилища);
		ПараметрыЗадания.Добавить(АдресХранилищаСостояния);
		
		ПараметрыВызоваМетода = Новый Массив();
		ПараметрыВызоваМетода.Добавить("Обработки.НастройкаРазрешенийНаИспользованиеВнешнихРесурсов.ВыполнитьОбработкуЗапросовОбновления");
		ПараметрыВызоваМетода.Добавить(ПараметрыЗадания);
		
	ИначеЕсли РежимОтключения Тогда
		
		ПараметрыЗадания = Новый Массив();
		ПараметрыЗадания.Добавить(АдресХранилища);
		ПараметрыЗадания.Добавить(АдресХранилищаСостояния);
		
		ПараметрыВызоваМетода = Новый Массив();
		ПараметрыВызоваМетода.Добавить("Обработки.НастройкаРазрешенийНаИспользованиеВнешнихРесурсов.ВыполнитьОбработкуЗапросовОтключения");
		ПараметрыВызоваМетода.Добавить(ПараметрыЗадания);
		
	ИначеЕсли РежимВосстановления Тогда
		
		ПараметрыЗадания = Новый Массив();
		ПараметрыЗадания.Добавить(АдресХранилища);
		ПараметрыЗадания.Добавить(АдресХранилищаСостояния);
		
		ПараметрыВызоваМетода = Новый Массив();
		ПараметрыВызоваМетода.Добавить("Обработки.НастройкаРазрешенийНаИспользованиеВнешнихРесурсов.ВыполнитьОбработкуЗапросовВосстановления");
		ПараметрыВызоваМетода.Добавить(ПараметрыЗадания);
		
	Иначе
		
		ПараметрыЗадания = Новый Массив();
		ПараметрыЗадания.Добавить(Запросы);
		ПараметрыЗадания.Добавить(АдресХранилища);
		ПараметрыЗадания.Добавить(АдресХранилищаСостояния);
		
		ПараметрыВызоваМетода = Новый Массив();
		ПараметрыВызоваМетода.Добавить("Обработки.НастройкаРазрешенийНаИспользованиеВнешнихРесурсов.ВыполнитьОбработкуЗапросов");
		ПараметрыВызоваМетода.Добавить(ПараметрыЗадания);
		
	КонецЕсли;
	
	Задание = ФоновыеЗадания.Выполнить("ОбщегоНазначения.ВыполнитьМетодКонфигурации",
			ПараметрыВызоваМетода,
			,
			НСтр("ru = 'Обработка запросов на использование внешних ресурсов...';
				|en = 'Processing requests for external resources…'"));
	
	ИдентификаторЗадания = Задание.УникальныйИдентификатор;
	
	Возврат АдресХранилища;
	
КонецФункции

&НаКлиенте
Процедура ПроверитьОбработкуЗапросов()
	
	Попытка
		Готовность = ЗапросыОбработаны(ИдентификаторЗадания);
	Исключение
		ЗаданиеАктивно = Ложь;
		Результат = Новый Структура();
		Результат.Вставить("КодВозврата", КодВозвратаДиалога.Отмена);
		Закрыть(Результат);
		ВызватьИсключение;
	КонецПопытки;
	
	Если Готовность Тогда
		ЗаданиеАктивно = Ложь;
		ЗавершитьОбработкуЗапросов();
	Иначе
		
		ИтерацияПроверки = ИтерацияПроверки + 1;
		
		Если ИтерацияПроверки = 2 Тогда
			ПодключитьОбработчикОжиданияОбработкиЗапросов(5);
		ИначеЕсли ИтерацияПроверки = 3 Тогда
			ПодключитьОбработчикОжиданияОбработкиЗапросов(8);
		Иначе
			ПодключитьОбработчикОжиданияОбработкиЗапросов(10);
		КонецЕсли;
		
	КонецЕсли;
	
КонецПроцедуры

&НаСервереБезКонтекста
Функция ЗапросыОбработаны(Знач ИдентификаторЗадания)
	
	Задание = ФоновыеЗадания.НайтиПоУникальномуИдентификатору(ИдентификаторЗадания);
	
	Если Задание <> Неопределено
		И Задание.Состояние = СостояниеФоновогоЗадания.Активно Тогда
		
		Возврат Ложь;
	КонецЕсли;
	
	Если Задание = Неопределено Тогда
		ВызватьИсключение(НСтр("ru = 'Непредвиденная ситуация при обработке запросов разрешений на использование внешних ресурсов.';
								|en = 'An unexpected error occurred while processing permission requests to use external resources.'"));
	КонецЕсли;
	
	Если Задание.Состояние = СостояниеФоновогоЗадания.ЗавершеноАварийно Тогда
		ОшибкаЗадания = Задание.ИнформацияОбОшибке;
		Если ОшибкаЗадания <> Неопределено Тогда
			ВызватьИсключение(ОбработкаОшибок.ПодробноеПредставлениеОшибки(ОшибкаЗадания));
		Иначе
			ВызватьИсключение(НСтр("ru = 'Не удалось обработать запросы разрешений на использование внешних ресурсов.';
									|en = 'Cannot process permission requests to use external resources.'"));
		КонецЕсли;
	ИначеЕсли Задание.Состояние = СостояниеФоновогоЗадания.Отменено Тогда
		ВызватьИсключение(НСтр("ru = 'Не удалось обработать запросы разрешений на использование внешних ресурсов, т.к. задание было отменено администратором.';
								|en = 'Cannot process permission requests to use external resources as the administrator canceled the job.'"));
	Иначе
		ИдентификаторЗадания = Неопределено;
		Возврат Истина;
	КонецЕсли;
	
КонецФункции

&НаКлиенте
Процедура ЗавершитьОбработкуЗапросов()
	
	ЗаданиеАктивно = Ложь;
	
	Если Открыта() Тогда
		
		Результат = Новый Структура();
		Результат.Вставить("КодВозврата", КодВозвратаДиалога.ОК);
		Результат.Вставить("АдресХранилищаСостояния", АдресХранилищаСостояния);
		
		Закрыть(Результат);
		
	Иначе
		
		ОписаниеОповещения = ЭтотОбъект.ОписаниеОповещенияОЗакрытии;
		Если ОписаниеОповещения <> Неопределено Тогда
			ВыполнитьОбработкуОповещения(ОписаниеОповещения, КодВозвратаДиалога.ОК);
		КонецЕсли;
		
	КонецЕсли;
	
КонецПроцедуры

&НаСервереБезКонтекста
Процедура ОтменитьОбработкуЗапросов(Знач ИдентификаторЗадания)
	
	Задание = ФоновыеЗадания.НайтиПоУникальномуИдентификатору(ИдентификаторЗадания);
	
	Если Задание = Неопределено ИЛИ Задание.Состояние <> СостояниеФоновогоЗадания.Активно Тогда
		Возврат;
	КонецЕсли;
	
	Попытка
		Задание.Отменить();
	Исключение
		// Возможно задание как раз в этот момент закончилось и ошибки нет.
		ЗаписьЖурналаРегистрации(НСтр("ru = 'Настройка разрешений на использование внешних ресурсов.Отмена выполнения фонового задания';
										|en = 'External resource permission setup.Cancel background job'", ОбщегоНазначения.КодОсновногоЯзыка()),
			УровеньЖурналаРегистрации.Ошибка, , , ОбработкаОшибок.ПодробноеПредставлениеОшибки(ИнформацияОбОшибке()));
	КонецПопытки;
	
КонецПроцедуры

&НаКлиенте
Процедура ПодключитьОбработчикОжиданияОбработкиЗапросов(Знач Интервал)
	
	ПодключитьОбработчикОжидания("ПроверитьОбработкуЗапросов", Интервал, Истина);
	
КонецПроцедуры

#КонецОбласти