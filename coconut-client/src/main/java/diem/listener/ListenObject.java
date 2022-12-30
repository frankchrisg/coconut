package diem.listener;

public class ListenObject {

    public String getKey() {
        return key;
    }

    public void setKey(final String key) {
        this.key = key;
    }

    private String key;

    @Override
    public String toString() {
        return "ListenObject{" +
                ", id='" + key + '\'' +
                '}';
    }
}
