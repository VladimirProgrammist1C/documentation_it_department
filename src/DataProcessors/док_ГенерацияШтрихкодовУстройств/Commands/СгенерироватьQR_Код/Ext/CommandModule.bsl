﻿
&НаКлиенте
Процедура ОбработкаКоманды(ПараметрКоманды, ПараметрыВыполненияКоманды)
	Если СтрНайти(ПараметрыВыполненияКоманды.Источник.ИмяФормы,"ФормаСписка") = 0 Тогда
		ПараметрыФормы = Новый Структура("СсылкаНаОбъект", ПараметрыВыполненияКоманды.Источник.Параметры.Ключ);
	Иначе
		ПараметрыФормы = Новый Структура("СсылкаНаОбъект", ПараметрыВыполненияКоманды.Источник.Элементы.Список.ТекущаяСтрока);
	КонецЕсли;
	ОткрытьФорму("Обработка.док_ГенерацияШтрихкодовУстройств.Форма", ПараметрыФормы, ПараметрыВыполненияКоманды.Источник, ПараметрыВыполненияКоманды.Уникальность, ПараметрыВыполненияКоманды.Окно, ПараметрыВыполненияКоманды.НавигационнаяСсылка);
КонецПроцедуры
