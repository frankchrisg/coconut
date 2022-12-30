package diem.helper;

public class AccountInformation {

    private String privateKey;

    public AccountInformation(final String privateKeyConstructor, final String publicKeyConstructor,
                              final String accountAddressConstructor, final String authKeyConstructor) {
        this.privateKey = privateKeyConstructor;
        this.publicKey = publicKeyConstructor;
        this.accountAddress = accountAddressConstructor;
        this.authKey = authKeyConstructor;
    }

    public String getPrivateKey() {
        return privateKey;
    }

    public void setPrivateKey(final String privateKey) {
        this.privateKey = privateKey;
    }

    public String getPublicKey() {
        return publicKey;
    }

    public void setPublicKey(final String publicKey) {
        this.publicKey = publicKey;
    }

    public String getAccountAddress() {
        return accountAddress;
    }

    public void setAccountAddress(final String accountAddress) {
        this.accountAddress = accountAddress;
    }

    public String getAuthKey() {
        return authKey;
    }

    public void setAuthKey(final String authKey) {
        this.authKey = authKey;
    }

    private String publicKey;
    private String accountAddress;
    private String authKey;

    @Override
    public String toString() {
        return "AccountInformation{" +
                "privateKey='" + privateKey + '\'' +
                ", publicKey='" + publicKey + '\'' +
                ", accountAddress='" + accountAddress + '\'' +
                ", authKey='" + authKey + '\'' +
                '}';
    }
}
