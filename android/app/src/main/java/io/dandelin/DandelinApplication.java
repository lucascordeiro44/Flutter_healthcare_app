package io.dandelin;

import io.flutter.app.FlutterApplication;

public class DandelinApplication extends FlutterApplication {

    private String doctorName;
    private String doctorExpertise;
    private String doctorAvatar;

    public String getDoctorName() {
        return doctorName;
    }

    public void setDoctorName(String doctorName) {
        this.doctorName = doctorName;
    }

    public String getDoctorExpertise() {
        return doctorExpertise;
    }

    public void setDoctorExpertise(String doctorExpertise) {
        this.doctorExpertise = doctorExpertise;
    }

    public String getDoctorAvatar() {
        return doctorAvatar;
    }

    public void setDoctorAvatar(String doctorAvatar) {
        this.doctorAvatar = doctorAvatar;
    }
}
