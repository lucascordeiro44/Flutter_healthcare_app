package io.dandelin;

import android.content.res.Configuration;
import android.os.Bundle;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.view.WindowManager;
import android.widget.ImageView;
import android.widget.TextView;
import android.widget.Toast;
import android.widget.Toolbar;

import androidx.annotation.NonNull;

import com.squareup.picasso.Picasso;

import java.util.concurrent.TimeUnit;

import io.reactivex.Observable;
import io.reactivex.android.schedulers.AndroidSchedulers;
import io.reactivex.disposables.CompositeDisposable;
import io.reactivex.functions.Consumer;
import io.reactivex.schedulers.Schedulers;
import us.zoom.sdk.MeetingActivity;

public class LivetouchMeetingActivity extends MeetingActivity {

    private CompositeDisposable compositeDisposable = new CompositeDisposable();

    private void setupToolbar() {
        DandelinApplication application = (DandelinApplication) getApplication();
        Toolbar toolbar = findViewById(R.id.toolbar);
        TextView title = findViewById(R.id.toolbarTitle);
        TextView subtitle = findViewById(R.id.toolbarSubtitle);
        ImageView avatar = findViewById(R.id.toolbarAvatar);
        setActionBar(toolbar);
        if(getActionBar() != null) {
            getActionBar().setDisplayHomeAsUpEnabled(true);
            getActionBar().setDisplayShowHomeEnabled(true);
            getActionBar().setDisplayShowTitleEnabled(false);
        }
        title.setText(application.getDoctorName());
        subtitle.setText(application.getDoctorExpertise());
        try {
            String avatarUrl = application.getDoctorAvatar();
            if (avatarUrl != null) {
                Picasso.get().load(application.getDoctorAvatar()).into(avatar);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

//    @Override
//    public boolean onCreateOptionsMenu(Menu menu) {
//        getMenuInflater().inflate(R.menu.meeting_toolbar_menu, menu);
//        return true;
//    }

    @Override
    public boolean onOptionsItemSelected(@NonNull MenuItem item) {
        if (item.getItemId() == android.R.id.home) {
            showLeaveDialog();
        }
        return super.onOptionsItemSelected(item);
    }

    @Override
    protected int getLayout() {
        return R.layout.activity_livetouch_meeting;
    }

    @Override
    protected boolean isAlwaysFullScreen() {
        return false;
    }

    @Override
    protected boolean isSensorOrientationEnabled() {
        return false;
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        compositeDisposable.add(Observable
                .interval(250, TimeUnit.MILLISECONDS)
                .subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(new Consumer<Long>() {
                    @Override
                    public void accept(Long aLong) {
                        updateButtonsStatus();
                    }
                }));

        disableFullScreenMode();
        setupToolbar();
        setupView();
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        compositeDisposable.clear();
    }

    private void setupView() {

        View btnLeaveZoomMeeting = findViewById(R.id.meeting_footer_quit_btn_container);
        btnLeaveZoomMeeting.setOnClickListener(new View.OnClickListener() {

            @Override
            public void onClick(View v) {
                showLeaveDialog();
            }
        });

        View btnAudio = findViewById(R.id.meeting_footer_mic_btn_container);
        btnAudio.setOnClickListener(new View.OnClickListener() {

            @Override
            public void onClick(View v) {
                muteAudio(!isAudioMuted());
            }
        });

        View btnVideo = findViewById(R.id.meeting_footer_cam_btn_container);
        btnVideo.setOnClickListener(new View.OnClickListener() {

            @Override
            public void onClick(View v) {
                muteVideo(!isVideoMuted());
            }
        });
    }

    @Override
    public void onConfigurationChanged(Configuration newConfig) {
        super.onConfigurationChanged(newConfig);
        disableFullScreenMode();
    }

    private void disableFullScreenMode() {
        getWindow().setFlags(~WindowManager.LayoutParams.FLAG_FULLSCREEN, WindowManager.LayoutParams. FLAG_FULLSCREEN);
    }

    private void updateButtonsStatus() {

        // Audio button
        ImageView ivAudio = findViewById(R.id.meeting_footer_mic_img);
        boolean audioState = isAudioMuted();
        ivAudio.setImageResource(audioState ? R.drawable.ic_baseline_mic_off_24 : R.drawable.ic_baseline_mic_24);
        ivAudio.setColorFilter(getResources().getColor(audioState ? R.color.gray : R.color.accent));

        // Video button
        ImageView ivVideo = findViewById(R.id.meeting_footer_cam_img);
        boolean videoState = isVideoMuted();
        ivVideo.setImageResource(videoState ? R.drawable.ic_baseline_videocam_off_24 : R.drawable.ic_baseline_videocam_24);
        ivVideo.setColorFilter(getResources().getColor(videoState ? R.color.gray : R.color.accent));
    }
}
