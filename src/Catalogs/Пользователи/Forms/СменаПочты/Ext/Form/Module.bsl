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
	
	СтараяПочта = Параметры.СтараяПочта;
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура СменитьПочту(Команда)
	
	Если Не ПроверитьЗаполнение() Тогда
		Возврат;
	КонецЕсли;
	
	Если Не ЗначениеЗаполнено(СтараяПочта) Тогда
		ТекстВопроса =
			НСтр("ru = 'Адрес электронной почты пользователя сервиса будет установлен.
			           |Владельцы и администраторы абонента больше не смогут изменять параметры пользователя.
			           |
			           |Выполнить установку адреса электронной почты?';
			           |en = 'Адрес электронной почты пользователя сервиса будет установлен.
			           |Владельцы и администраторы абонента больше не смогут изменять параметры пользователя.
			           |
			           |Выполнить установку адреса электронной почты?'");
	Иначе
		ТекстВопроса = НСтр("ru = 'Выполнить изменение адреса электронной почты?';
							|en = 'Do you want to change the email address?'");
	КонецЕсли;
	
	ПоказатьВопрос(
		Новый ОписаниеОповещения("СменитьПочтуПродолжение", ЭтотОбъект),
		ТекстВопроса,
		РежимДиалогаВопрос.ДаНетОтмена);
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаКлиенте
Процедура СменитьПочтуПродолжение(Ответ, Контекст) Экспорт
	
	Если Ответ = КодВозвратаДиалога.Да Тогда
		Закрыть(НоваяПочта);
	ИначеЕсли Ответ = КодВозвратаДиалога.Нет Тогда
		Закрыть(Неопределено);
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти
