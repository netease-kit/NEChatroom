package androidx.lifecycle;

import java.lang.reflect.Field;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;

import androidx.annotation.Keep;
import androidx.annotation.NonNull;

import static androidx.lifecycle.Lifecycle.State.DESTROYED;

/**
 *
 */
@Keep
public class InitAwareLiveData<T> extends MediatorLiveData<T> {

//    @Override
    //    public void observe(@NonNull LifecycleOwner owner, @NonNull Observer observer) {
    //        if (owner.getLifecycle().getCurrentState() == DESTROYED) {
    //            // ignore
    //            return;
    //        }
    //        LifecycleBoundObserver wrapper = new LifecycleBoundObserver(owner, observer);
    //        wrapper.mLastVersion = getVersion();
    //        LifecycleBoundObserver existing = (LifecycleBoundObserver) getExisting(observer, wrapper);
    //        if (existing != null && !existing.isAttachedTo(owner)) {
    //            throw new IllegalArgumentException("Cannot add the same observer with different lifecycles");
    //        }
    //        if (existing != null) {
    //            return;
    //        }
    //        owner.getLifecycle().addObserver(wrapper);
    //    }

    public void observeInitAware(@NonNull LifecycleOwner owner, @NonNull Observer<T> observer) {
        if (owner.getLifecycle().getCurrentState() == DESTROYED) {
            // ignore
            return;
        }
        LifecycleBoundObserver wrapper = new LifecycleBoundObserver(owner, observer);
        wrapper.mLastVersion = getVersion();
        LifecycleBoundObserver existing = (LifecycleBoundObserver) getExisting(observer, wrapper);
        if (existing != null && !existing.isAttachedTo(owner)) {
            throw new IllegalArgumentException("Cannot add the same observer with different lifecycles");
        }
        if (existing != null) {
            return;
        }
        owner.getLifecycle().addObserver(wrapper);
    }

    private Object getExisting(@NonNull Observer observer, LifecycleBoundObserver wrapper) {
        try {
            Field mObservers = LiveData.class.getDeclaredField("mObservers");
            mObservers.setAccessible(true);
            Object o = mObservers.get(this);
            Method putIfAbsent = o.getClass().getMethod("putIfAbsent", Object.class, Object.class);
            return putIfAbsent.invoke(o, observer, wrapper);
        } catch (NoSuchFieldException e) {
            e.printStackTrace();
        } catch (IllegalAccessException e) {
            e.printStackTrace();
        } catch (NoSuchMethodException e) {
            e.printStackTrace();
        } catch (InvocationTargetException e) {
            e.printStackTrace();
        }
        return null;
    }
}
