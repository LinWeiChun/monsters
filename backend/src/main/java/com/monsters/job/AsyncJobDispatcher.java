package com.monsters.job;

public interface AsyncJobDispatcher {

    void dispatch(AsyncJob job);
}
