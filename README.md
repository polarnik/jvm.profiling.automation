# JVM profiling automation
Автоматизация профилирования JVM с SJK, AWK, Bash, Telegraf, InfluxDB, Grafana в Linux.

Документация: /docs

## Задача

При реализации CI/CD для тестирования производительности появляются задачи автоматизации всех этапов тестирования:

* подготовка стенда
* запуск теста
* мониторинг
* профилирование (как более детальный вариант мониторинга)

В том числе профилирование JVM должно выполняться автоматически или его запуск должен быть автоматизирован.
Большая часть метрик, собираемых во время тестирования, доступны посредством Grafana и хранятся в InfluxDB.
А для профилирования Java используется Java Fligth Recorder (JFR) и 
Swiss Java Knife (SJK). Которые сохраняют резульататы профилирования в своем формате - бинарном, текстовом, графическом.

И появились следующие задачи:

* сохранение результатов профилирования с привязкой ко времени, стенду, версии автоматически;
* визуализация результатов профилирования в Grafana, чтобы все результаты были в едином виде.

Появились технические проблемы:

* простой запуск JFR и SJK, автоматизация процесса;
* периодический запуск профилирования JFR и SJK;
* сохранение результатов JFR и SJK в InfluxDB;
* визуализация результатов профилирования.

## Концепт

На примере Apache.JMeter будет показано, как автоматизировать профилирование JVM.
Автоматически сохранить результаты профилирования в InfluxDB и визуализировать в Grafana.

В качестве тестового сайта используется httpbin:
```shell script
sudo docker run -p 80:80 kennethreitz/httpbin
```


## Версии программного обеспечения

Используется операционная система
Ubuntu 18.04.3 LTS.

Профилироваться будет Apache JMeter 5.1.1.

Профилирование будет для JVM от Oracle

```
java version "1.8.0_181"
Java(TM) SE Runtime Environment (build 1.8.0_181-b13)
Java HotSpot(TM) 64-Bit Server VM (build 25.181-b13, mixed mode)
```

Версия Java до "1.8.0_202" включительно являются бесплатными.

В данном проекте показаны наработки по профилированию JVM на Linux с помощью:

* **sjk** 0.14 https://github.com/aragozin/jvm-tools
* **awk** GNU Awk 4.1.4, API: 1.1 https://www.gnu.org/software/gawk/manual/gawk.html
* **bash** GNU bash, версия 4.4.20(1)-release (x86_64-pc-linux-gnu)
* **Telegraf** v1.7.4 https://github.com/influxdata/telegraf + https://www.influxdata.com/time-series-platform/telegraf/
* **InfluxDB** 1.1.1 https://www.influxdata.com/time-series-platform/
* **Grafana** 5.2.4 https://grafana.com/

Версии awk, bash, Telegraf, InfluxDB, Grafana взяты из репозитория Ubuntu 18.04.3 LTS на момент 28 августа 2019 года.

Версия sjk взята с https://github.com/aragozin/jvm-tools/releases

## Доска Grafana

https://grafana.com/grafana/dashboards/10839

## Нагружаемое приложение
```shell script
sudo docker run -p 80:80 kennethreitz/httpbin
```
