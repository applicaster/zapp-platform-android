package com.applicaster.ui.utils;

import java.util.HashSet;

public enum RTL_LOCALES {
    ARABIC("ar"),
    ARAMAIC("arc"),
    DIVEHI("dv"),
    FARSI("fa"),
    HAUSA("ha"),
    HEBREW("he"),
    ISRAEL("iw"), // JDK can send "iw" has locale instead of he when using hebrew language
    KHOWAR("khw"),
    KASHMIRI("ks"),
    KURDISH("ku"),
    PASHTO("ps"),
    URDU("ur"),
    YIDDISH("yi");

    private String locale;

    RTL_LOCALES(String localeValue) {
        this.locale = localeValue;
    }

    private static HashSet<String> getStringValues() {
        RTL_LOCALES[] locales = RTL_LOCALES.values();
        HashSet<String> localesList = new HashSet<>();

        for (RTL_LOCALES rawLocale : locales) {
            localesList.add(rawLocale.locale);
        }

        return localesList;
    }

    public static boolean includes(String requestedLocale) {
        return getStringValues().contains(requestedLocale);
    }
}

