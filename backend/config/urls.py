from django.contrib import admin
from django.http import JsonResponse
from django.urls import include, path


def health(request):
    return JsonResponse({'status': 'ok', 'service': 'backend'})

urlpatterns = [
    path('admin/', admin.site.urls),
    path('health/', health),
    path('api/', include('tasks.urls')),
]
