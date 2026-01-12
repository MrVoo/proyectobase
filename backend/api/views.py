from rest_framework.decorators import api_view
from rest_framework.response import Response
from rest_framework import status


@api_view(['GET'])
def health_check(request):
    """Simple health check endpoint"""
    return Response({
        'status': 'ok',
        'message': 'API is running'
    })


@api_view(['GET'])
def api_root(request):
    """API root endpoint"""
    return Response({
        'message': 'Welcome to the API',
        'endpoints': {
            'health': '/api/health/',
            'api-root': '/api/'
        }
    })
