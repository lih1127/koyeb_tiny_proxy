const axios = require('axios');

// 1. 환경 변수(PROXY_URL) 또는 커맨드 라인 인자에서 프록시 주소를 가져옵니다.
const proxyHost = process.env.PROXY_URL || process.argv[2];

// 2. 프록시 주소가 입력되지 않았으면, 사용법을 안내하고 스크립트를 종료합니다.
if (!proxyHost) {
    console.error('❌ 에러: 프록시 서버 주소가 지정되지 않았습니다.');
    console.error('\n사용법 1 (커맨드 라인 인자):');
    console.error('  node test_proxy.js <your-koyeb-app-url>');
    console.error('\n사용법 2 (환경 변수):');
    console.error('  PROXY_URL=<your-koyeb-app-url> node test_proxy.js');
    process.exit(1); // 에러 코드로 종료
}

// --- 설정 ---
const proxyPort = 80;
const targetUrl = 'http://httpbin.org/ip';

console.log(`프록시 서버 ${proxyHost}:${proxyPort} 를 통해 ${targetUrl} 에 요청을 보냅니다...`);
console.log('--------------------------------------------------');

axios.get(targetUrl, {
    // Axios 프록시 설정
    proxy: {
        host: proxyHost,
        port: proxyPort,
        protocol: 'http'
    }
})
.then(response => {
    console.log('✅ 테스트 성공!');
    console.log(`응답 받은 IP 주소: ${response.data.origin}`);
    console.log('이 IP 주소는 Koyeb 서버의 IP와 일치해야 합니다.');
})
.catch(error => {
    console.error('❌ 테스트 실패!');
    if (error.response) {
        console.error(`에러 상태 코드: ${error.response.status}`);
        console.error('응답 데이터:', error.response.data);
    } else if (error.request) {
        console.error('응답을 받지 못했습니다. 프록시 서버 주소, 포트 또는 네트워크 연결을 확인하세요.');
    } else {
        console.error('요청 설정 중 에러 발생:', error.message);
    }
});