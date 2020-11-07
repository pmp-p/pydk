# https://developer.android.com/guide/components/activities/activity-lifecycle


def onCreate(self, pyvm):
    print("onCreate", pyvm)


def onStart(self, pyvm):
    print("onStart", pyvm)


def onPause(self, pyvm):
    print("onPause", pyvm)


def onResume(self, pyvm):
    print("onResume", pyvm)


def onStop(self, pyvm):
    print("onStop", pyvm)


def onDestroy(self, pyvm):
    print("onDestroy", pyvm)

print('Applications ready')


