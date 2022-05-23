from django.urls import path

from dudlik.users.views import HomepageView

app_name = "users"

urlpatterns = [
    path('', HomepageView.as_view(), name="homepage"),
]
