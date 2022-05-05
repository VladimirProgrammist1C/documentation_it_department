﻿///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2021, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////
#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область ОбработчикиСобытий

Процедура УстановкаПараметровСеанса(ИменаПараметровСеанса)
	
	// СтандартныеПодсистемы
	СтандартныеПодсистемыСервер.УстановкаПараметровСеанса(ИменаПараметровСеанса);
	// Конец СтандартныеПодсистемы
	
	Если ИменаПараметровСеанса <>  Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	ТекущийСтиль = ХранилищеОбщихНастроек.Загрузить(
		"СтильОформления",
		"Стиль");
	
	Если ТекущийСтиль = Неопределено Тогда
		ГлавныйСтиль = Новый Стиль;
	Иначе
		Попытка
			ГлавныйСтиль = БиблиотекаСтилей[ТекущийСтиль];
		Исключение
		    ПодробнаяИнформацияОбОшибке = ПодробноеПредставлениеОшибки(ИнформацияОбОшибке());
			ТекстОшибки = СтрШаблон("Не удалось установить главный стиль ""%1"" по причине:
				|%2",
				ТекущийСтиль,
				ПодробнаяИнформацияОбОшибке);
			ЗаписьЖурналаРегистрации(
				"Установка главного стиля приложения",
				УровеньЖурналаРегистрации.Предупреждение,
				,,
				ТекстОшибки);
		КонецПопытки;	 
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#КонецЕсли