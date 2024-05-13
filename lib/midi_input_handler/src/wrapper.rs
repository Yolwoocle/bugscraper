use std::ops::{Deref, DerefMut};

pub struct Wrapper<T>(T);

unsafe impl<T> Sync for Wrapper<T> {}

impl<T> Deref for Wrapper<T> {
    type Target = T;

    fn deref(&self) -> &Self::Target {
        &self.0
    }
}
impl<T> DerefMut for Wrapper<T> {
    fn deref_mut(&mut self) -> &mut Self::Target {
        &mut self.0
    }
}

impl<T> Wrapper<T> {
    pub fn new(inner: T) -> Self {
        Self(inner)
    }
}
