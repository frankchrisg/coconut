package diem.helper;

import co.paralleluniverse.fibers.Suspendable;

import java.io.File;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.stream.Collectors;

public class AccountStore {

    private AccountStore() {
    }

    @Suspendable
    public static List<AccountInformation> getAccountInformationList(final String fileName) {
        if (accountInformationList == null) {
            accountInformationList = readAccountInformationFromFile(fileName);
            return accountInformationList;
        }
        return accountInformationList;

    }

    @Suspendable
    public static List<String> getAddressList(final String fileName) {
        if (addressList == null) {
            getAccountInformationListUnmodifiable(fileName);
            addressList =
                    accountInformationListUnmodifiable.stream().map(AccountInformation::getAccountAddress).collect(Collectors.toList());
        }
        return addressList;
    }

    @Suspendable
    public synchronized static List<AccountInformation> getSublist(final int offset) {
        List<AccountInformation> accountInformationListTmp = new ArrayList<>(accountInformationList.subList(0, offset));
        accountInformationList.removeIf(accountInformationListTmp::contains);
        return accountInformationListTmp;
    }

    private static List<String> addressList;
    private static List<AccountInformation> accountInformationList;
    private static List<AccountInformation> accountInformationListUnmodifiable;

    @Suspendable
    public static List<AccountInformation> getAccountInformationListUnmodifiable(final String fileName) {
        if (accountInformationListUnmodifiable == null) {
            accountInformationListUnmodifiable = readAccountInformationFromFile(fileName);
            return accountInformationListUnmodifiable;
        }
        return Collections.unmodifiableList(accountInformationListUnmodifiable);
    }

    @Suspendable
    private synchronized static List<AccountInformation> readAccountInformationFromFile(final String fileName) {
        return Helper.readAccountInformationFromFile(new File(fileName));
    }

}
