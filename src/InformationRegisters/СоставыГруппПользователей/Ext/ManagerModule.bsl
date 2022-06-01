﻿///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2022, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область СлужебныеПроцедурыИФункции

// Процедура обновляет все данные регистра.
//
// Параметры:
//  ЕстьИзменения - Булево - (возвращаемое значение) - если производилась запись,
//                  устанавливается Истина, иначе не изменяется.
//
Процедура ОбновитьДанныеРегистра(ЕстьИзменения = Неопределено) Экспорт
	
	УстановитьПривилегированныйРежим(Истина);
	
	Блокировка = Новый БлокировкаДанных;
	Блокировка.Добавить("РегистрСведений.СоставыГруппПользователей");
	
	НачатьТранзакцию();
	Попытка
		Блокировка.Заблокировать();
		
		// Обновление связей пользователей.
		УчастникиИзменений = Новый Соответствие;
		ИзмененныеГруппы   = Новый Соответствие;
		
		Выборка = Справочники.ГруппыПользователей.Выбрать();
		Пока Выборка.Следующий() Цикл
			ПользователиСлужебный.ОбновитьСоставыГруппПользователей(
				Выборка.Ссылка, , УчастникиИзменений, ИзмененныеГруппы);
		КонецЦикла;
		
		// Обновление связей внешних пользователей.
		Выборка = Справочники.ГруппыВнешнихПользователей.Выбрать();
		Пока Выборка.Следующий() Цикл
			ПользователиСлужебный.ОбновитьСоставыГруппВнешнихПользователей(
				Выборка.Ссылка, , УчастникиИзменений, ИзмененныеГруппы);
		КонецЦикла;
		
		Если УчастникиИзменений.Количество() > 0
		 ИЛИ ИзмененныеГруппы.Количество() > 0 Тогда
		
			ЕстьИзменения = Истина;
			
			ПользователиСлужебный.ПослеОбновленияСоставовГруппПользователей(
				УчастникиИзменений, ИзмененныеГруппы);
		КонецЕсли;
		
		ПользователиСлужебный.ОбновитьРолиВнешнихПользователей();
		
		ЗафиксироватьТранзакцию();
	Исключение
		ОтменитьТранзакцию();
		ВызватьИсключение;
	КонецПопытки;
	
КонецПроцедуры

#КонецОбласти

#КонецЕсли